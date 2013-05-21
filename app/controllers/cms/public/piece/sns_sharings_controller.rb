# encoding: utf-8
class Cms::Public::Piece::SnsSharingsController < Sys::Controller::Public::Base
  
  def index
    @item  = Page.current_item
    @piece = Page.current_piece
    
    if @item.respond_to?(:sns_link_state)
      return render(:text => nil) if @item.sns_link_state == "hidden"
    end
    
    @uri = Page.full_uri
    
    types = @piece.setting_value(:link_types)
    types = types.to_s.split(' ')
    
    @tweet    = types.index("tweet")
    @fb_like  = types.index("fb_like")
    @fb_share = types.index("fb_share")
    @gp_share = types.index("gp_share")
  end
end
