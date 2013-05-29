# encoding: utf-8
module Portal::Controller::Feed
  def render_feed(docs)
    if ['rss', 'atom'].index(params[:format])
      @skip_layout = true
      @site_uri    = Page.site.full_uri
      @node_uri    = @site_uri.gsub(/\/$/, '') + Page.current_node.public_uri
      @req_uri     = @site_uri.gsub(/\/$/, '') + Page.uri
      @feed_name   = "#{Page.title} | #{Page.site.name}"
      @entry_ids   = {}
      
      data = nil
      if params[:format] == "rss"
        data = to_rss(docs) 
      elsif params[:format] == "atom"
        data = to_atom(docs) 
      end
      return render :xml => unescape(data)
    end
    return false
  end

  def unescape(xml)
    xml = xml.to_s
    #xml = CGI.unescapeHTML(xml)
    #xml = xml.gsub(/&amp;/, '&')
    xml.gsub(/&#(?:(\d*?)|(?:[xX]([0-9a-fA-F]{4})));/) { [$1.nil? ? $2.to_i(16) : $1.to_i].pack('U') }
  end

  def strimwidth(str, size, options = {})
    suffix = options[:suffix] || '..'
    str    = str.sub!(/<[^<>]*>/,"") while /<[^<>]*>/ =~ str
    chars  = str.split(//u)
    return chars.size <= size ? str : chars.slice(0, size).join('') + suffix
  end

  def to_rss(docs)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.rss('version' => '2.0') do

      xml.channel do
        xml.title       @feed_name
        xml.link        @req_uri
        xml.language    "ja"
        xml.description Page.title

        docs.each do |entry|
          xml.item do
            xml.title        entry.title
            xml.link         entry.public_full_uri
            xml.description  strimwidth(entry.summary.to_s.gsub(/&nbsp;/, ' '), 500)
            xml.pubDate      entry.entry_updated.rfc822
            
            if entry.doc_id
              entry.doc.category_items.each do |category|
                xml.category   category.title
              end
            else
              entry.categories.split(/\r\n|\r|\n/).each do |label|
                next if label =~ /\// && label !~ /^分野\//
                xml.category   label.gsub(/.*\//, '')
              end
            end
          end
        end #docs

      end #channel
    end #xml
  end
  
  def to_atom(docs)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct! :xml, :version => 1.0, :encoding => 'UTF-8'
    xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do

      updated = (docs[0] && docs[0].published_at) ? docs[0].published_at : Date.today
      
      xml.id      "tag:#{Page.site.domain},#{Page.site.created_at.strftime('%Y')}:#{Page.current_node.public_uri}"
      xml.title   @feed_name
      xml.updated updated.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1')
      xml.link    :rel => 'alternate', :href => @node_uri
      xml.link    :rel => 'self', :href => @req_uri, :type => 'application/atom+xml', :title => @feed_name

      docs.each do |doc|
        if doc.doc_id
          @entry_id = "tag:#{::Page.site.domain},#{doc.doc.created_at.strftime('%Y')}:#{doc.doc.public_uri}"
        else
          @entry_id = doc.entry_id
        end
        next if @entry_ids[@entry_id]
        @entry_ids[@entry_id] = true
        
        xml.entry do
          if doc.doc_id
            to_atom_doc(xml, doc)
          else
            to_atom_entry(xml, doc)
          end
        end #entry
      end #docs
    end #feed
  end
  
  def to_atom_doc(xml, entry)
    doc = entry.doc
    
    xml.id      @entry_id
    xml.title   doc.title
    xml.updated doc.published_at.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1') #.rfc822
    xml.summary(:type => 'html') do |p|
      p.cdata! strimwidth(doc.body, 500)
    end
    xml.link    :rel => 'alternate', :href => doc.public_full_uri

    if (c = doc.unit) && (node = doc.content.unit_node)
      xml.category :term => c.name, :scheme => node.public_full_uri, :label => "組織/#{c.node_label}"
    end

    if node = doc.content.category_node
      doc.category_items.each do |c|
        xml.category :entry => c.name, :scheme => node.public_full_uri, :label => "分野/#{c.node_label}"
      end
    end

    if node = doc.content.attribute_node
      doc.attribute_items.each do |c|
        xml.category :term => c.name, :scheme => node.public_full_uri, :label => "属性/#{c.node_label}"
      end
    end

    if node = doc.content.area_node
      doc.area_items.each do |c|
        xml.category :term => c.name, :scheme => node.public_full_uri, :label => "地域/#{c.node_label}"
      end
    end

    if doc.event_state == 'visible' && doc.event_date && node = doc.content.event_node
      xml.category :term => 'event', :scheme => node.public_full_uri,
        :label => "イベント/#{doc.event_date.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1')}"
    end
    
    xml.author do |auth|
      if doc.inquiry && doc.inquiry.group
        name  = doc.inquiry.group.full_name
        name += "　#{doc.inquiry.charge}" if !doc.inquiry.charge.blank?
        auth.name  "#{name}"
        auth.email "#{doc.inquiry.email}"
      end
      #auth.uri "#{uri}#{doc.unit.name}/"
    end

    if node = doc.content.tag_node
      doc.tags.each do |c|
        xml.link :rel => 'tag', :href => "#{node.public_full_uri}#{CGI::escape(c.word)}", :type => 'text/xhtml'
      end
    end

    doc.rel_docs.each do |c|
      xml.link :rel => 'related', :href => "#{c.public_full_uri}", :type => 'text/xhtml'
    end
  end
  
  def to_atom_entry(xml, entry)
    xml.id      @entry_id
    xml.title   entry.title
    xml.updated entry.entry_updated.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1') #.rfc822
    xml.summary(:type => 'html') do |p|
      p.cdata! strimwidth(entry.summary, 500)
    end
    xml.link    :rel => 'alternate', :href => entry.public_full_uri
    
    entry.categories.split(/\r\n|\r|\n/).each do |label|
      xml.category :label => label
    end
    
    xml.author do |auth|
      auth.name  entry.author_name
      auth.email entry.author_email if entry.author_email
    end if entry.author_name
  end
end