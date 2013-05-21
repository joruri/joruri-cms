# encoding: utf-8
class Tourism::Public::Node::Spot::PhotosController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper
  
  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    #@spots_uri = @content.public_uri('Tourism::Spot')
  end
  
  def index
    spot = Tourism::Spot.new.public_or_preview
    spot.and :content_id, Page.current_node.content.id
    spot.and :name, params[:name]
    return http_error(404) unless @spot = spot.find(:first)

    if Core.mode == 'preview' && params[:spot_id]
      cond = {:id => params[:spot_id], :content_id => @spot.content_id, :name => @spot.name}
      return http_error(404) unless @spot = Tourism::Spot.find(:first, :conditions => cond)
    end
    
    Page.current_item = @spot
    Page.title        = @spot.title + " フォトギャラリー"
    
    @spot.bread_crumbs_type = :photo
    
    item = Tourism::Photo.new.public
    item.and :spot_id, @spot.id
    item.page 1, (request.mobile? ? 10 : 60)
    @items = item.find(:all, :order => 'updated_at DESC')
  end
end
