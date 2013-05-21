# encoding: utf-8
class Portal::Script::FeedEntriesController < Cms::Controller::Script::Publication
  def publish
    if @node
      uri  = "#{@node.public_uri}"
      path = "#{@node.public_path}"
      publish_more(@node, :uri => uri, :path => path, :first => 2)
      publish_page(@node, :uri => "#{uri}index.rss" , :path => "#{path}index.rss", :dependent => :rss)
      publish_page(@node, :uri => "#{uri}index.atom", :path => "#{path}index.atom", :dependent => :atom)
    end
    render :text => "OK"
  end
end
