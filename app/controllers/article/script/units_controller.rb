# encoding: utf-8
class Article::Script::UnitsController < Cms::Controller::Script::Publication
  def publish
    _site = @node.site

    attrs = Article::Attribute
            .published
            .where(state: 'public', content_id: @node.content_id)
    if (attr_id = params[:target_child_id]).present?
      attrs = attrs.where(id: attr_id) 
    end
    attrs = attrs.order(:sort_no)
    
    if (target_id = params[:target_id]).present?
      
      units = Article::Unit.where(id: target_id).each do |item|
        uri  = "#{@node.public_uri}#{item.name}/"
        path = "#{@node.public_path}#{item.name}/"
        publish_page(item, uri: uri, path: path, site: _site)
        publish_more(item, uri: uri, path: path, site: _site, file: 'more', dependent: :more)
        publish_page(item, uri: "#{uri}index.rss", path: "#{path}index.rss", site: _site, dependent: :rss)
        publish_page(item, uri: "#{uri}index.atom", path: "#{path}index.atom", site: _site, dependent: :atom)

        attrs.each do |attr|
          uri  = "#{@node.public_uri}#{item.name}/#{attr.name}/"
          path = "#{@node.public_path}#{item.name}/#{attr.name}/"
          publish_more(item, rel_unid: attr.unid, uri: uri, path: path, site: _site, dependent: "/#{attr.name}")
        end
      end

    else
      Article::Unit.root_item.public_children.each do |item|
        uri  = "#{@node.public_uri}#{item.name}/"
        path = "#{@node.public_path}#{item.name}/"
        publish_page(item, uri: uri, path: path, site: _site)
        publish_more(item, uri: uri, path: path, site: _site, file: 'more', dependent: :more)
        publish_page(item, uri: "#{uri}index.rss", path: "#{path}index.rss", site: _site, dependent: :rss)
        publish_page(item, uri: "#{uri}index.atom", path: "#{path}index.atom", site: _site, dependent: :atom)
  
        attrs.each do |attr|
          uri  = "#{@node.public_uri}#{item.name}/#{attr.name}/"
          path = "#{@node.public_path}#{item.name}/#{attr.name}/"
          publish_more(item, rel_unid: attr.unid, uri: uri, path: path, site: _site, dependent: "/#{attr.name}")
        end
  
        item.public_children.each do |c|
          uri  = "#{@node.public_uri}#{c.name}/"
          path = "#{@node.public_path}#{c.name}/"
          publish_page(c, uri: uri, path: path, site: _site)
          publish_more(c, uri: uri, path: path, site: _site, file: 'more', dependent: :more)
          publish_page(c, uri: "#{uri}index.rss", site: _site, path: "#{path}index.rss", dependent: :rss)
          publish_page(c, uri: "#{uri}index.atom", site: _site, path: "#{path}index.atom", dependent: :atom)
  
          attrs.each do |attr|
            uri  = "#{@node.public_uri}#{c.name}/#{attr.name}/"
            path = "#{@node.public_path}#{c.name}/#{attr.name}/"
            publish_more(c, rel_unid: attr.unid, uri: uri, path: path, site: _site, dependent: "/#{attr.name}")
          end
        end
      end
    end

    render text: (@errors.empty? ? 'OK' : @errors.join("\n"))
  end
end
