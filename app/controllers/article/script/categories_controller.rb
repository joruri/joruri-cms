# encoding: utf-8
class Article::Script::CategoriesController < Cms::Controller::Script::Publication
  def publish
    units = Article::Unit.find_departments(web_state: 'public')
    if (unit_id = params[:target_child_id]).present?
      units = units.where(id: unit_id) 
    end

    if (target_id = params[:target_id]).present?
      Article::Category.where(id: target_id).each do |item|
        if item.level_no <= 1
          publish_children(nil, item, [])
        else
          publish_children(nil, item, units)
        end
      end
    else
      cond = { state: 'public', content_id: @node.content_id }
      Article::Category.root_items(cond).each do |item|
        uri  = "#{@node.public_uri}#{item.name}/"
        path = "#{@node.public_path}#{item.name}/"
        publish_page(item, uri: uri, path: path)
        publish_more(item, uri: uri, path: path, file: 'more', dependent: :more)
        publish_page(item, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
        publish_page(item, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)
  
        item.public_children.each do |c|
          publish_children(item, c, units)
  
          c.public_children.each do |c2|
            publish_children(item, c2, units)
  
            c2.public_children.each do |c3|
              publish_children(item, c3, units)
            end
          end
        end
      end
    end

    render text: (@errors.empty? ? 'OK' : @errors.join("\n"))
  end

  def publish_children(_item, child, units)
    uri  = "#{@node.public_uri}#{child.name}/"
    path = "#{@node.public_path}#{child.name}/"
    publish_page(child, uri: uri, path: path)
    publish_more(child, uri: uri, path: path, file: 'more', dependent: :more)
    publish_page(child, uri: "#{uri}index.rss", path: "#{path}index.rss", dependent: :rss)
    publish_page(child, uri: "#{uri}index.atom", path: "#{path}index.atom", dependent: :atom)

    units.each do |unit|
      uri  = "#{@node.public_uri}#{child.name}/#{unit.name}/"
      path = "#{@node.public_path}#{child.name}/#{unit.name}/"
      publish_more(child, rel_unid: unit.unid, uri: uri, path: path, dependent: "/#{unit.name}")
    end
  end
end
