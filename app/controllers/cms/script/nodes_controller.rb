# encoding: utf-8
class Cms::Script::NodesController < Cms::Controller::Script::Publication

  def publish
    @ids  = {}

    Cms::Node.new.public.find(:all, :conditions => {:parent_id => 0}, :order => "directory DESC, name, id").each do |node|
      if params[:target] == 'top'
        publish_index(node)
      else
        publish_node(node)
      end
    end

    render :text => "OK"
  end

  def publish_index(node)
    item = Cms::Node.new.find(:first, :conditions => {:parent_id => node.id, :name => 'index.html'})
    return unless item

    uri  = "#{item.public_uri}?node_id=#{item.id}"
    publish_page(item, :uri => uri, :site => item.site, :path => item.public_path)
  end

  def publish_node(node)
    return if @ids.key?(node.id)
    @ids[node.id] = 1

    return unless node.site
    last_name = nil

    cond = ["parent_id = ? AND name IS NOT NULL AND name != ''", node.id]
    nodes = Cms::Node.new.find(:all, :select => :id, :conditions => cond, :order => "directory, name, id").each do |v|
      item = Cms::Node.find_by_id(v[:id])
      next unless item
      next if item.name.blank? || item.name == last_name
      last_name = item.name

      if !item.public?
        item.close_page
        next
      end

      ## page
      if item.model == 'Cms::Page'
        begin
          uri  = "#{item.public_uri}?node_id=#{item.id}"
          publish_page(item, :uri => uri, :site => item.site, :path => item.public_path)
        rescue Script::InterruptException => e
          raise e
        rescue => e
          Script.error "#{item.class}##{item.id} #{e}"
        end
        next
      end

      ## modules' page
      if item.model != 'Cms::Directory'
        begin
          model = item.model.underscore.pluralize.gsub(/^(.*?)\//, '\1/script/')
          next unless eval("#{model.camelize}Controller").publishable?

          publish_page(item, :uri => item.public_uri, :site => item.site, :path => item.public_path)
          res = render_component_into_view :controller => model, :action => "publish", :params => params.merge(:node => item)

        rescue Script::InterruptException => e
          raise e
        rescue LoadError => e
          Script.error "#{item.class}##{item.id} #{e}"
          next
        rescue Exception => e
          Script.error "#{item.class}##{item.id} #{e}"
          next
        end
        #next
      end

      publish_node(item)
    end
  end

  def publish_by_task
    item = params[:item]

    if item.state == 'recognized' && item.model == "Cms::Page"
      Script.current

      item = Cms::Node::Page.find(item.id)
      uri  = "#{item.public_uri}?node_id=#{item.id}"
      path = "#{item.public_path}"

      if !item.publish(render_public_as_string(uri, :site => item.site))
        raise item.errors.full_messages
      end

      ruby_uri  = (uri =~ /\?/) ? uri.gsub(/(.*\.html)\?/, '\\1.r?') : "#{uri}.r"
      ruby_path = "#{path}.r"
      if item.published? || !::Storage.exists?(ruby_path)
        item.publish_page(render_public_as_string(ruby_uri, :site => item.site),
          :path => ruby_path, :dependent => :ruby)
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

    if item.state == 'public' && item.model == "Cms::Page"
      Script.current

      item = Cms::Node::Page.find(item.id)
      item.close
      params[:task].destroy

      Script.success
    end

    render(:text => "OK")
  rescue => e
    raise "#{item.class}##{item.id} #{e}"
  end
end
