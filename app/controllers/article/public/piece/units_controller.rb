# encoding: utf-8
class Article::Public::Piece::UnitsController < Sys::Controller::Public::Base
  def index
    @content = Article::Content::Doc.find(Page.current_piece.content_id)
    @node = @content.unit_node
    
    @item = Page.current_item
    @items = []
    
    if @node
      @public_uri = @node.public_uri
      
      if !@item.instance_of?(Article::Unit)
        if item = Article::Unit.root_item
          @items = item.public_children
        end
      else
        @items = @item.public_children
      end
    end
    
    return render :text => '' if @items.size == 0
  end
end
