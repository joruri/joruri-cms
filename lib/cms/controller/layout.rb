# encoding: utf-8
module Cms::Controller::Layout
  @skip_layout = nil
  @no_cache    = nil
  
  def render_public_as_string(path, options = {})
    if path =~ /\.html\.r$/
      return nil unless Joruri.config[:cms_use_kana]
    end
    
    Core.publish = true unless options[:preview]
    mode = Core.set_mode('preview')
    
    qp = {}
    if path =~ /\?/
      qp   = Rack::Utils.parse_query(path.gsub(/.*\?/, ''))
      path = path.gsub(/\?.*/, '')
    end
  
    Page.initialize
    Page.site   = options[:site] || Core.site
    Page.uri    = path
    Page.mobile = options[:mobile]
    
    begin
      env  = {}
      node = Core.search_node(path)
      opt  = _routes.recognize_path(node, env)
      opt  = qp.merge(opt)
      ctl  = opt[:controller]
      act  = opt[:action]
      opt[:authenticity_token] = params[:authenticity_token] if params[:authenticity_token]
      
      body   = render_component_into_view :controller => ctl, :action => act, :params => opt
      errstr = "Action Controller: Exception caught"
      raise(errstr) if body.index("<title>#{errstr}</title>")
    rescue => e
      Page.error = 404
    end
    
    error = Page.error
    Page.initialize
    Page.site = options[:site] || Core.site ##
    Page.uri  = path                        ##
    
    Core.set_mode(mode)
    
    return error ? nil : body
  end
  
  def render_public_layout
    if Rails.env.to_s == 'production' && !@no_cache
      # enable cache
      headers.delete("Cache-Control")
      # no cache
      #response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      #response.headers["Pragma"] = "no-cache"
      #response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
    
    return true if @performed_redirect
    return true if @skip_layout
    return true if params[:format] && params[:format] != 'html'
    return true if Page.error
    
    Page.current_item = Page.current_node unless Page.current_item
    
    ## content
    Page.content = response.body
    self.response_body = nil
    
    if Page.ruby 
      return http_error(404) unless Joruri.config[:cms_use_kana]
    end
    
    #response.content_type = nil
    #erase_render_results
    #reset_variables_added_to_assigns
    #@template.instance_variable_set("@content_for_layout", '')
    
    ## concept
    concepts = Cms::Lib::Layout.inhertited_concepts
    
    ## layout
    if Page.layout
      #
    elsif Core.set_mode('preview') && params[:layout_id]
     Page.layout = Cms::Layout.find(params[:layout_id]) # emergency
    elsif layout = Cms::Lib::Layout.inhertited_layout
      Page.layout    = layout.clone
      Page.layout.id = layout.id
    else
      Page.layout = Cms::Layout.new({
        :body             => '[[content]]',
        :mobile_body      => '[[content]]',
        :smart_phone_body => '[[content]]'
      })
      return render :text => Page.content, :layout => 'layouts/public/base'
    end
    
    body = (Page.layout.body_tag(request) || '').clone.to_s
    
    ## render the piece
    Cms::Lib::Layout.find_design_pieces(body, concepts, params).each do |name, item|
      Page.current_piece = item
      begin
        next if item.content_id && !item.content
        mnames= item.model.underscore.pluralize.split('/')
        data = render_component_into_view :params => params,
          :controller => mnames[0] + '/public/piece/' + mnames[1], :action => 'index'
        if data =~ /^<html/ && Rails.env.to_s == 'production'
          # component error
        else
          body.gsub!("[[piece/#{name}]]", piece_container_html(item, data))
        end
      rescue => e
        #
      end
    end
    
    ## render the content
    body.gsub!("[[content]]", Page.content)
    
    ## render the data/text
    Cms::Lib::Layout.find_data_texts(body, concepts).each do |name, item|
      data = item.body
      body.gsub!("[[text/#{name}]]", data)
    end
    
    ## render the data/file
    Cms::Lib::Layout.find_data_files(body, concepts).each do |name, item|
      data = ''
      if item.image_file?
        data = '<img src="' + item.public_uri + '" alt="' + item.title + '" title="' + item.title + '" />'
      else
        data = '<a href="' + item.public_uri + '" class="' + item.css_class + '" target="_blank">' + item.united_name + '</a>'
      end
      body.gsub!("[[file/#{name}]]", data)
    end
    
    ## render the emoji
    require 'jpmobile' #v0.0.4
    body.gsub!(/\[\[emoji\/([0-9a-zA-Z\._-]+)\]\]/) do |m|
      name = m.gsub(/\[\[emoji\/([0-9a-zA-Z\._-]+)\]\]/, '\1')
      Cms::Lib::Mobile::Emoji.convert(name, request.mobile)
    end

    ## removes the unknown components
    body.gsub!(/\[\[[a-z]+\/[^\]]+\]\]/, '') #if Core.mode.to_s != 'preview'
    
    ## mobile
    if request.mobile?
      begin
        require 'tamtam'
        body = TamTam.inline(
          :css  => Page.layout.tamtam_css,
          :body => body
        )
      rescue => e #InvalidStyleException
        error_log(e)
      end
      
      case request.mobile
      when Jpmobile::Mobile::Docomo
        # for docomo
        headers["Content-Type"] = "application/xhtml+xml; charset=utf-8"
      when Jpmobile::Mobile::Au
        # for au
      when Jpmobile::Mobile::Softbank
        # for SoftBank
      when Jpmobile::Mobile::Willcom
        # for Willcom
      else
        # for PC
      end
    end
    
    ## ruby(kana)
    if Page.ruby
      body = Cms::Lib::Navi::Kana.convert(body)
    end
    
#    ## for preview
#    if Core.mode.to_s == 'preview'
#      body.gsub!(/<a .*?href="\/[^_].*?>/i) do |m|
#        prefix = "/_preview/#{format('%08d', Page.site.id)}"
#        m.gsub(/(<a .*?href=")(\/[^_].*?>)/i, '\1' + prefix + '\2')
#      end
#    end
    
    body = last_convert_body(body)
    
    ## render the true layout
    render :text => body.force_encoding('utf-8'), :layout => 'layouts/public/base'
  end
  
  def last_convert_body(body)
    body
  end
  
  def piece_container_html(piece, body)
    return "" if body.blank?
    
    title = piece.view_title
    return body if piece.model == 'Cms::Free' && title.blank?
    
    html  = %Q(<div#{piece.css_attributes}>\n)
    html << %Q(<div class="pieceContainer">\n)
    html << %Q(<div class="pieceHeader"><h2>#{title}</h2></div>\n) if !title.blank?
    html << %Q(<div class="pieceBody">#{body}</div>\n)
    html << %Q(</div>\n)
    html << %Q(<!-- end .piece --></div>\n)
    html.html_safe
  end
end
