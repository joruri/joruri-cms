# encoding: utf-8
class Article::Public::Piece::AreasController < Sys::Controller::Public::Base
  def index
    @content = Article::Content::Doc.find(Page.current_piece.content_id)
    @node = @content.area_node
    
    @item = Page.current_item
    @items = []
    
    if @node
      @public_uri = @node.public_uri
      
      if !@item.instance_of?(Article::Area)
        @items = Article::Area.root_items(:content_id => @content.id)
      else
        @items = @item.public_children
      end
    end
    
    return render :text => '' if @items.size == 0
  end
end
