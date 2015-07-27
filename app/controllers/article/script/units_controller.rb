# encoding: utf-8
class Article::Script::UnitsController < Cms::Controller::Script::Publication
  def publish
    _site = @node.site
    cond = {:state => 'public', :content_id => @node.content_id}

    attrs = Article::Attribute.new.public.find(:all, :conditions => cond, :order => :sort_no)

    Article::Unit.root_item.public_children.each do |item|
      uri  = "#{@node.public_uri}#{item.name}/"
      path = "#{@node.public_path}#{item.name}/"
      publish_page(item, :uri => uri, :path => path, :site => _site)
      publish_more(item, :uri => uri, :path => path, :site => _site, :file => 'more', :dependent => :more)
      publish_page(item, :uri => "#{uri}index.rss", :path => "#{path}index.rss", :site => _site, :dependent => :rss)
      publish_page(item, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :site => _site, :dependent => :atom)
      
      attrs.each do |attr|
        uri  = "#{@node.public_uri}#{item.name}/#{attr.name}/"
        path = "#{@node.public_path}#{item.name}/#{attr.name}/"
        publish_more(item, :rel_unid => attr.unid, :uri => uri, :path => path, :site => _site, :dependent => "/#{attr.name}")
      end
      
      item.public_children.each do |c|
        uri  = "#{@node.public_uri}#{c.name}/"
        path = "#{@node.public_path}#{c.name}/"
        publish_page(c, :uri => uri, :path => path, :site => _site)
        publish_more(c, :uri => uri, :path => path, :site => _site, :file => 'more', :dependent => :more)
        publish_page(c, :uri => "#{uri}index.rss", :site => _site, :path => "#{path}index.rss", :dependent => :rss)
        publish_page(c, :uri => "#{uri}index.atom", :site => _site, :path => "#{path}index.atom", :dependent => :atom)
      
        attrs.each do |attr|
          uri  = "#{@node.public_uri}#{c.name}/#{attr.name}/"
          path = "#{@node.public_path}#{c.name}/#{attr.name}/"
          publish_more(c, :rel_unid => attr.unid, :uri => uri, :path => path, :site => _site, :dependent => "/#{attr.name}")
        end
      end
    end
      
    render :text => (@errors.size == 0 ? "OK" : @errors.join("\n"))
  end
end
