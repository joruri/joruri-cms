# encoding: utf-8
class Cms::Script::NodesController < Cms::Controller::Script::Publication
  def publish
    @ids = {}

    content_id = params[:target_content_id]
    
    case params[:target_module]
    when 'cms'
      if (target_node = Cms::Node.where(id: params[:target_node_id]).first)
        publish_node(target_node)
      end
    when 'article'
      if !params[:target_node].nil?
        publish_article_node(params[:target_node])
      elsif (target_node = Cms::Node.where(id: params[:target_node_id]).first)
        publish_node(target_node)
      end
    else
      Cms::Node.published
               .where(parent_id: 0)
               .order(directory: :desc, name: :asc, id: :asc)
               .each do |node|
        publish_node(node)
      end
    end

    render text: 'OK'
  end

  def publish_node(node)
    article_nodes = ['Article::Category', 'Article::Attribute', 
                     'Article::Area', 'Article::Unit']
    return if params[:all].nil? && node.model.in?(article_nodes)

    return if @ids.key?(node.id)
    @ids[node.id] = 1

    started_at = Time.now

    return unless node.site

    unless node.public?
      node.close_page
      return
    end

    ## page
    if node.model == 'Cms::Page'
      begin
        uri = "#{node.public_uri}?node_id=#{node.id}"
        publish_page(node, uri: uri, site: node.site, path: node.public_path)
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error "#{node.class}##{node.id} #{e}"
      end
      return
    end
    
    ## modules' page
    unless node.model == 'Cms::Directory'
      begin
        model = node.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/script/')
        return unless eval("#{model.camelize}Controller").publishable?

        publish_page(node, uri: node.public_uri, site: node.site, path: node.public_path)
        res = render_component_into_view controller: model, action: 'publish', params: params.merge(node: node)

      rescue Script::InterruptException => e
        raise e
      rescue LoadError => e
        Script.error "#{node.class}##{node.id} #{e}"
        return
      rescue Exception => e
        Script.error "#{node.class}##{node.id} #{e}"
        return
      end
    end
    
    last_name = nil
    nodes = Cms::Node.arel_table
    Cms::Node.where(parent_id: node.id)
             .where(nodes[:name].not_eq(nil).and(nodes[:name].not_eq('')).and(nodes[:name].not_eq(last_name)))
             .order('directory, name, id').each do |child_node|
      last_name = child_node.name
      publish_node(child_node)
    end
    
  end

  def publish_all
    params[:all] = 'all'

    @ids = {}
    Cms::Node.published
             .where(parent_id: 0)
             .order(directory: :desc, name: :asc, id: :asc)
             .each do |node|
      publish_node(node)
    end
    
    render text: 'OK'
  end

  def publish_top
    @ids = {}

    Cms::Node.published
             .where(parent_id: 0)
             .order(directory: :desc, name: :asc, id: :asc)
             .each do |node|
      publish_index(node)
    end

    render text: 'OK'
  end

  def publish_index(node)
    item = Cms::Node.where(parent_id: node.id, name: 'index.html').first
    return unless item

    uri  = "#{item.public_uri}?node_id=#{item.id}"
    publish_page(item, uri: uri, site: item.site, path: item.public_path)
  end
  
  def publish_category
    @ids = {}

    params[:all] = 'all'
    publish_article_node('category')
    render text: 'OK'
  end

  def publish_attribute
    @ids = {}

    params[:all] = 'all'
    publish_article_node('attribute')
    render text: 'OK'
  end

  def publish_area
    @ids = {}

    params[:all] = 'all'
    publish_article_node('area')
    render text: 'OK'
  end

  def publish_unit
    @ids = {}

    params[:all] = 'all'
    publish_article_node('unit')
    render text: 'OK'
  end

  def publish_article_node(type)
    Article::Content::Doc.all.each do |content|
      node = nil
      case type
      when 'category'
        node = content.category_node
      when 'attribute'
        node = content.attribute_node
      when 'area'
        node = content.area_node
      when 'unit'
        node = content.unit_node
      end
      next unless node
      publish_node(node)
    end
  end

  def publish_by_task
    item = params[:item]

    if item.state == 'recognized' && item.model == 'Cms::Page'
      Script.current

      item = Cms::Node::Page.find(item.id)
      uri  = "#{item.public_uri}?node_id=#{item.id}"
      path = item.public_path.to_s

      unless item.publish(render_public_as_string(uri, site: item.site))
        raise item.errors.full_messages
      end

      ruby_uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1.r?') : "#{uri}.r"
      ruby_path = "#{path}.r"
      if item.published? || !::Storage.exists?(ruby_path)
        item.publish_page(render_public_as_string(ruby_uri, site: item.site),
                          path: ruby_path, dependent: :ruby)
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

    if item.state == 'public' && item.model == 'Cms::Page'
      Script.current

      item = Cms::Node::Page.find(item.id)
      item.close
      params[:task].destroy

      Script.success
    end

    render(text: 'OK')
  rescue => e
    raise "#{item.class}##{item.id} #{e}"
  end
end
