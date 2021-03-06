# encoding: utf-8
class Article::Script::AreasController < Cms::Controller::Script::Publication
  def publish
    attrs = Article::Attribute.published
                              .where(content_id: @node.content_id)
    if (attr_id = params[:target_child_id]).present?
      attrs = attrs.where(id: attr_id) 
    end
    attrs = attrs.order(:sort_no)
    
    if (target_id = params[:target_id]).present?
      Article::Area.where(id: target_id).each do |item|
        if item.level_no <= 1
          publish_children(nil, item, attrs)
        else
          publish_children(nil, item, [])
        end
      end
    else
      cond = { state: 'public', content_id: @node.content_id }
      Article::Area.root_items(cond).each do |item|
        uri  = "#{@node.public_uri}#{item.name}/"
        path = "#{@node.public_path}#{item.name}/"
        publish_page(item, uri: uri, path: path)
        publish_more(item, uri: uri, path: path, file: 'more', dependent: :more)
        publish_page(item, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
        publish_page(item, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)
  
        item.public_children.each do |c|
          publish_children(item, c, attrs)
  
          c.public_children.each do |c2|
            publish_children(item, c2, attrs)
  
            c2.public_children.each do |c3|
              publish_children(item, c3, attrs)
            end
          end
        end
      end
    end
    render text: (@errors.empty? ? 'OK' : @errors.join("\n"))
  end

  def publish_children(_item, child, attrs)
    uri  = "#{@node.public_uri}#{child.name}/"
    path = "#{@node.public_path}#{child.name}/"
    publish_page(child, uri: uri, path: path)
    publish_more(child, uri: uri, path: path, file: 'more', dependent: :more)
    publish_page(child, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(child, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)

    attrs.each do |attr|
      uri  = "#{@node.public_uri}#{child.name}/#{attr.name}/"
      path = "#{@node.public_path}#{child.name}/#{attr.name}/"
      publish_more(child, rel_unid: attr.unid, uri: uri, path: path, dependent: "/#{attr.name}")
    end
  end
end
