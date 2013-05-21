# encoding: utf-8
class Cms::Public::Node::SitemapsController < Cms::Controller::Public::Base
  def index
    @item = Page.current_node
    
    Page.current_item = @item
    Page.title        = @item.title
    
    item = Cms::Node.new.public
    item.and :route_id, Page.site.root_node.id
    item.and :directory, 1
    item.and :name, 'IS NOT', nil
    @items = item.find(:all, :order => :name)
    
    @children = lambda do |node|
      item = Cms::Node.new.public
      item.and :route_id, node.id
      item.and :name, 'IS NOT', nil
      #item.and :directory, 1
      item.find(:all, :order => "directory, name")
    end
  end
end
