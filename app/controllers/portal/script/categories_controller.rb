# encoding: utf-8
class Portal::Script::CategoriesController < Cms::Controller::Script::Publication
  def publish
    cond = {:state => 'public', :content_id => @node.content_id}
    Portal::Category.root_items(cond).each do |item|
      uri  = "#{@node.public_uri}#{item.name}/"
      path = "#{@node.public_path}#{item.name}/"
      publish_page(item, :uri => uri, :path => path)
      publish_more(item, :uri => uri, :path => path, :first => 2, :dependent => :more)
      publish_page(item, :uri => "#{uri}index.rss" , :path => "#{path}index.rss", :dependent => :rss)
      publish_page(item, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)

      item.public_children.each do |c|
        uri  = "#{@node.public_uri}#{c.name}/"
        path = "#{@node.public_path}#{c.name}/"
        publish_page(c, :uri => uri, :path => path)
        publish_more(c, :uri => uri, :path => path, :first => 2, :dependent => :more)
        publish_page(c, :uri => "#{uri}index.rss" , :path => "#{path}index.rss", :dependent => :rss)
        publish_page(c, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
      end
    end

    render :text => (@errors.size == 0 ? "OK" : @errors.join("\n"))
  end
end
