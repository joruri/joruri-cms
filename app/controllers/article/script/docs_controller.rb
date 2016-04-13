# encoding: utf-8
class Article::Script::DocsController < Cms::Controller::Script::Publication
  def rebuild
    ## options
    publish_files = Script.options[:file]
    content_id    = Script.options[:content_id]

    items = Article::Doc.published
    items = items.where(content_id: content_id) if content_id
    items = items.order(published_at: :desc).select(:id)

    Script.total items.size

    items.each_with_index do |v, _idx|
      item = v.class.find_by(id: v.id)
      next unless item

      Script.current

      begin
        uri  = "#{item.public_uri}?doc_id=#{item.id}"
        path = item.public_path
        content = render_public_as_string(uri, site: item.content.site)
        if item.rebuild(content, file: publish_files)
          Script.success if item.published?
          uri = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
          content = render_public_as_string(uri, site: item.content.site)
          item.publish_page(content, path: "#{path}.r", uri: uri, dependent: :ruby)
        end
      rescue Script::InterruptException => e
        raise e
      rescue Exception => e
        Script.error "#{item.class}##{item.id} #{e}"
      end
    end

    render(text: 'OK')
  end

  def publish
    uri  = @node.public_uri.to_s
    path = @node.public_path.to_s
    publish_more(@node, uri: uri, path: path, first: 2)
    render(text: 'OK')
  end

  def publish_by_task
    item = params[:item]

    if item.state == 'recognized'
      Script.current

      uri  = "#{item.public_uri}?doc_id=#{item.id}"
      path = item.public_path.to_s

      unless item.publish(render_public_as_string(uri, site: item.content.site))
        raise item.errors.full_messages.join(' ')
      end

      ruby_uri  = (uri =~ /\?/) ? uri.gsub(/\?/, 'index.html.r?') : "#{uri}index.html.r"
      ruby_path = "#{path}.r"

      if item.published? || !::Storage.exists?(ruby_path)
        item.publish_page(render_public_as_string(ruby_uri, site: item.content.site),
                          path: ruby_path, uri: ruby_uri, dependent: :ruby)
      end
      params[:task].destroy

      Script.success
    end

    render(text: 'OK')
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

    render(text: 'OK')
  rescue => e
    raise "#{item.class}##{item.id} #{e}"
  end
end
