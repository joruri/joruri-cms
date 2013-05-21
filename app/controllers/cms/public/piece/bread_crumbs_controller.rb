# encoding: utf-8
class Cms::Public::Piece::BreadCrumbsController < Sys::Controller::Public::Base
  def index
    @piece = Page.current_piece
    @item  = Page.current_item
    
    @top_label = @piece.setting_value(:top_label)
    
    if defined?(@item.bread_crumbs)
      @bread_crumbs = @item.bread_crumbs(Page.current_node)
    else
      @bread_crumbs = Page.current_node.bread_crumbs
    end
  end
end
