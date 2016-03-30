# encoding: utf-8
class Portal::Public::Piece::CategoriesController < Sys::Controller::Public::Base
  def index
    @content = Portal::Content::FeedEntry.find(Page.current_piece.content_id)
    @node = @content.category_node

    @item = Page.current_item
    @items = []

    if @node
      @public_uri = @node.public_uri

      @items = if !@item.instance_of?(Portal::Category)
                 Portal::Category.root_items(content_id: @content.id)
               else
                 @item.public_children
               end
    end

    return render text: '' if @items.size == 0
  end
end
