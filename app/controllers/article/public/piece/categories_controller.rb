# encoding: utf-8
class Article::Public::Piece::CategoriesController < Sys::Controller::Public::Base
  def index
    @content = Article::Content::Doc.find(Page.current_piece.content_id)
    @node = @content.category_node

    @item = Page.current_item
    @items = []

    if @node
      @public_uri = @node.public_uri

      @items = if !@item.instance_of?(Article::Category)
                 Article::Category.root_items(content_id: @content.id)
               else
                 @item.public_children
               end
    end

    return render text: '' if @items.empty?
  end
end
