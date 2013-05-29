# encoding: utf-8
class Faq::Script::CategoriesController < Cms::Controller::Script::Publication
  def publish
    cond = {:state => 'public', :content_id => @node.content_id}
    Faq::Category.root_items(cond).each do |item|
      uri  = "#{@node.public_uri}#{item.name}/"
      path = "#{@node.public_path}#{item.name}/"
      publish_page(item, :uri => uri, :path => path)
      publish_more(item, :uri => uri, :path => path, :file => 'more', :dependent => :more)
      publish_page(item, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => :rss)
      publish_page(item, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
      
      item.public_children.each do |c|
        publish_children(item, c)
        
        c.public_children.each do |c2|
          publish_children(item, c2)
          
          c2.public_children.each do |c3|
            publish_children(item, c3)
          end
        end
      end
    end
    
    render :text => (@errors.size == 0 ? "OK" : @errors.join("\n"))
  end
  
  def publish_children(item, child)
    uri  = "#{@node.public_uri}#{child.name}/"
    path = "#{@node.public_path}#{child.name}/"
    publish_page(child, :uri => uri, :path => path)
    publish_more(child, :uri => uri, :path => path, :file => 'more', :dependent => :more)
    publish_page(child, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :dependent => :rss)
    publish_page(child, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
  end
end
