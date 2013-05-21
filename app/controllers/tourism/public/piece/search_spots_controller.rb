# encoding: utf-8
class Tourism::Public::Piece::SearchSpotsController < Sys::Controller::Public::Base
  def index
    @piece   = Page.current_piece
    @content = Tourism::Content::Spot.find(@piece.content_id)
    
    @node = @content.search_spot_node
    return render(:text => '') unless @node
    
    @form_type = @piece.setting_value(:form_type)
    @form_type = "select" if @form_type.blank?
    
    @search_uri = @node.public_uri
    
    @genres = Tourism::Genre.root_items(:content_id => @content.id)
    @areas  = Tourism::Area.root_items(:content_id => @content.id)
    
    @s_genre_id = params[:s_genre_id]
    @s_area_id  = params[:s_area_id]
    
    @item = Tourism::Spot.new
    @item.s_genre_id = @s_genre_id
    @item.s_area_id  = @s_area_id
  end
end
