# encoding: utf-8
class Cms::Script::NodesController < Cms::Controller::Script::Publication
  include Sys::Lib::File::Transfer

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
      nodes = Cms::Node.arel_table

      close_nodes = Cms::Node.where(nodes[:state].eq('closed').and(nodes[:model].eq('Cms::Directory'))).all
      
      @close_node_ids = []
      down = lambda do |node|
        next if @close_node_ids.include?(node.id)
        @close_node_ids << node.id
        items = Cms::Node
               .where(parent_id: node.id)
               .where(model: 'Cms::Directory')
               .order(:parent_id, :name)
               
        items.each do |i|
          down.call(i)
        end
      end
      
      close_nodes.each do |node|
        down.call(node)
      end
      @close_node_ids.uniq!

      c1 = nodes.grouping(nodes[:model].not_eq('Cms::Directory').and(nodes[:directory].eq(1)))
      c2 = nodes[:model].eq('Cms::Page')
      c3 = nodes[:model].eq('Cms::Sitemap')

      c4 = nodes[:parent_id].not_in(@close_node_ids)
      
      ##public content directory & cms pages
      cnt = Cms::Node.published
                     .where(nodes.grouping(c1.or(c2.or(c3))).and(c4)).count
      
      Script.total cnt
      
      Cms::Node.published
               .where(parent_id: 0)
               .order(directory: :desc, name: :asc, id: :asc)
               .each do |node|
        publish_node(node)
      end
    end

    transfer_files() if transfer_to_publish?
    render text: 'OK'
  end

  def publish_node(node)
    article_nodes = ['Article::Category', 'Article::Attribute', 
                     'Article::Area', 'Article::Unit']
    if params[:all].nil? && node.model.in?(article_nodes)
      Script.current
      Script.success
      return
    end
    
    return if @ids.key?(node.id)
    @ids[node.id] = 1

    started_at = Time.now

    unless node.site
      Script.current
      Script.success
      return
    end

    if @close_node_ids && @close_node_ids.include?(node.parent_id)
      node.close_page unless node.public?
      return 
    end

    unless node.public?
      node.close_page
      return
    end

    ## page
    if node.model == 'Cms::Page'
      begin
        Script.current
        uri = "#{node.public_uri}?node_id=#{node.id}"
        res = publish_page(node, uri: uri, site: node.site, path: node.public_path)
        Script.success if res
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
        Script.current
        
        model = node.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/script/')
        unless eval("#{model.camelize}Controller").publishable?
          Script.success
          return
        end

        publish_page(node, uri: node.public_uri, site: node.site, path: node.public_path)
        res = render_component_into_view controller: model, action: 'publish', params: params.merge(node: node)
        Script.success if res

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
    publish
  end

  def publish_top
    @ids = {}
    
    items = []
    Cms::Node.published
             .where(parent_id: 0)
             .order(directory: :desc, name: :asc, id: :asc)
             .each do |node|
      item = Cms::Node.published
                      .where(parent_id: node.id, name: 'index.html').first
      items << item if item
    end
    Script.total items.size
    
    items.each do |item|
      Script.current
      
      uri  = "#{item.public_uri}?node_id=#{item.id}"
      res = publish_page(item, uri: uri, site: item.site, path: item.public_path)
      
      Script.success if res
    end

    transfer_files() if transfer_to_publish?
    render text: 'OK'
  end

  def publish_category
    @ids = {}

    params[:all] = 'all'
    publish_article_node('category')

    transfer_files() if transfer_to_publish?
    render text: 'OK'
  end

  def publish_attribute
    @ids = {}

    params[:all] = 'all'
    publish_article_node('attribute')

    transfer_files() if transfer_to_publish?
    render text: 'OK'
  end

  def publish_area
    @ids = {}

    params[:all] = 'all'
    publish_article_node('area')

    transfer_files() if transfer_to_publish?
    render text: 'OK'
  end

  def publish_unit
    @ids = {}

    params[:all] = 'all'
    publish_article_node('unit')

    transfer_files() if transfer_to_publish?
    render text: 'OK'
  end

  def publish_article_node(type)
    nodes = []
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
      nodes << node
    end
    
    Script.total nodes.size
    
    nodes.each do |node|
      publish_node(node)
    end

  end

  def publish_by_task
    item = params[:item]

    Script.current
    if item.state == 'recognized' && item.model == 'Cms::Page'
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
    end
    Script.success

    render(text: 'OK')
  rescue => e
    raise "#{item.class}##{item.id} #{e}"
  end

  def close_by_task
    item = params[:item]

    Script.current
    if item.state == 'public' && item.model == 'Cms::Page'
      item = Cms::Node::Page.find(item.id)
      item.close
      params[:task].destroy
    end
    Script.success

    render(text: 'OK')
  rescue => e
    raise "#{item.class}##{item.id} #{e}"
  end
end
