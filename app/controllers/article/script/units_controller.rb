# encoding: utf-8
class Article::Script::UnitsController < Cms::Controller::Script::Publication
  def publish
    attrs = Article::Attribute.new.public.find(:all, :order => :sort_no)

    cond = {:state => 'public', :content_id => @node.content_id}
    Article::Unit.root_item.public_children.each do |item|
      uri  = "#{@node.public_uri}#{item.name}/"
      path = "#{@node.public_path}#{item.name}/"
      publish_page(item, :uri => uri, :path => path)
      publish_more(item, :uri => uri, :path => path, :file => 'more', :dependent => :more)
      publish_page(item, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => :rss)
      publish_page(item, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
      
      attrs.each do |attr|
        uri  = "#{@node.public_uri}#{item.name}/#{attr.name}/"
        path = "#{@node.public_path}#{item.name}/#{attr.name}/"
        publish_more(item, :uri => uri, :path => path, :dependent => "/#{attr.name}")
      end
      
      item.public_children.each do |c|
        uri  = "#{@node.public_uri}#{c.name}/"
        path = "#{@node.public_path}#{c.name}/"
        publish_page(item, :uri => uri, :path => path, :dependent => "#{c.name}")
        publish_more(item, :uri => uri, :path => path, :file => 'more', :dependent => "#{c.name}/more")
        publish_page(item, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => "#{c.name}/rss")
        publish_page(item, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => "#{c.name}/atom")
        
        attrs.each do |attr|
          uri  = "#{@node.public_uri}#{c.name}/#{attr.name}/"
          path = "#{@node.public_path}#{c.name}/#{attr.name}/"
          publish_more(item, :uri => uri, :path => path, :dependent => "#{c.name}/#{attr.name}")
        end
      end
    end
    
    render :text => (@errors.size == 0 ? "OK" : @errors.join("\n"))
  end
end
