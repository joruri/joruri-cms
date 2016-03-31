# encoding: utf-8
class Cms::Public::Node::SitemapsController < Cms::Controller::Public::Base
  def index
    @item = Page.current_node

    Page.current_item = @item
    Page.title = @item.title

    @items = Cms::Node
             .published
             .where(route_id: Page.site.root_node.id)
             .where(directory: 1)
             .where.not(name: nil)
             .order(:name)

    @children = lambda do |node|
      item = Cms::Node
             .published
             .where(route_id: node.id)
             .where.not(name: nil)
             .order(:directory, :name)
    end
  end
end
