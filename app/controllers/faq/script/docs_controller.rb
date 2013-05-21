# encoding: utf-8
class Faq::Script::DocsController < Cms::Controller::Script::Publication
  
  def rebuild
    ## options
    publish_files = Script.options[:file]
    content_id    = Script.options[:content_id]
    
    item = Faq::Doc.new.public
    item.and :content_id, content_id if content_id
    items = item.find(:all, :select => "id", :order => 'published_at DESC')
    
    Script.total items.size
    
    items.each_with_index do |v, idx|
      item = v.class.find(v.id)
      next unless item
      
      Script.current
      
      begin
        uri     = "#{item.public_uri}?doc_id=#{item.id}"
        path    = item.public_path
        content = render_public_as_string(uri, :site => item.content.site)
        if item.rebuild(content)
          Script.success if item.published?
          uri     = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
          content = render_public_as_string(uri, :site => item.content.site)
          item.publish_page(content, :path => "#{path}.r", :uri => uri, :dependent => :ruby)
        end
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error "#{item.class}##{item.id} #{e}"
      end
    end
    
    return render(:text => "OK")
  end
  
  def publish
    uri  = "#{@node.public_uri}"
    path = "#{@node.public_path}"
    publish_more(@node, :uri => uri, :path => path, :first => 2)
    return render(:text => "OK")
  end
  
  def publish_by_task
    item = params[:item]
    
    if item.state == 'recognized'
      Script.current
      
      uri  = "#{item.public_uri}?doc_id=#{item.id}"
      path = "#{item.public_path}"
      
      if !item.publish(render_public_as_string(uri, :site => item.content.site))
        raise item.errors.full_messages.join(' ')
      end
      if item.published? || !::Storage.exists?("#{path}.r")
        item.publish_page(render_public_as_string("#{uri}index.html.r", :site => item.content.site),
          :path => "#{path}.r", :uri => "#{uri}index.html.r", :dependent => :ruby)
      end
      params[:task].destroy
      
      Script.success
    end
    
    render(:text => "OK")
  rescue => e
    raise "#{item.class}##{item.id} #{e}"
  end
  
  def close_by_task
    item = params[:item]
    
    if item.state == 'public'
      Script.current
      
      item.close
      params[:task].destroy
      
      Script.success
    end
    
    render(:text => "OK")
  rescue => e
    raise "#{item.class}##{item.id} #{e}"
  end
end
