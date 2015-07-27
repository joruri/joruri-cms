# encoding: utf-8
class Article::Script::AreasController < Cms::Controller::Script::Publication
  def publish
    attrs = Article::Attribute.new.public.find(:all, :conditions => "content_id = #{@node.content_id}", :order => :sort_no)
    
    cond = {:state => 'public', :content_id => @node.content_id}
    Article::Area.root_items(cond).each do |item|
      uri  = "#{@node.public_uri}#{item.name}/"
      path = "#{@node.public_path}#{item.name}/"
      publish_page(item, :uri => uri, :path => path)
      publish_more(item, :uri => uri, :path => path, :file => 'more', :dependent => :more)
      publish_page(item, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => :rss)
      publish_page(item, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
      
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
    
    render :text => (@errors.size == 0 ? "OK" : @errors.join("\n"))
  end
  
  def publish_children(item, child, attrs)
    uri  = "#{@node.public_uri}#{child.name}/"
    path = "#{@node.public_path}#{child.name}/"
    publish_page(child, :uri => uri, :path => path)
    publish_more(child, :uri => uri, :path => path, :file => 'more', :dependent => :more)
    publish_page(child, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => :rss)
    publish_page(child, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
    
    attrs.each do |attr|
      uri  = "#{@node.public_uri}#{child.name}/#{attr.name}/"
      path = "#{@node.public_path}#{child.name}/#{attr.name}/"
      publish_more(child, :rel_unid => attr.unid, :uri => uri, :path => path, :dependent => "/#{attr.name}")
    end
  end
end
