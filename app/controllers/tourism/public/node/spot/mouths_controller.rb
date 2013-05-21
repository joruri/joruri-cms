# encoding: utf-8
class Tourism::Public::Node::Spot::MouthsController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper
  
  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    #@spots_uri = @content.public_uri('Tourism::Spot')
    
    spot = Tourism::Spot.new.public_or_preview
    spot.and :content_id, Page.current_node.content.id
    spot.and :name, params[:name]
    return http_error(404) unless @spot = spot.find(:first)

    if Core.mode == 'preview' && params[:spot_id]
      cond = {:id => params[:spot_id], :content_id => @spot.content_id, :name => @spot.name}
      return http_error(404) unless @spot = Tourism::Spot.find(:first, :conditions => cond)
    end
    
    Page.current_item = @spot
    Page.title        = @spot.title + " クチコミ"
    
    @spot.bread_crumbs_type = :mouth
  end
  
  def index
    item = Tourism::Mouth.new.public
    item.and :spot_id, @spot.id
    item.page 1, (request.mobile? ? 10 : 20)
    @items = item.find(:all, :order => 'published_at DESC')
  end
  
  def new
    #@use_captcha     = @content.setting_value(:use_captcha) == "1"
    @use_captcha = 1
    
    @item = Tourism::Mouth.new(params[:item])
    @item.state        = 'closed'
    @item.content_id   = @content.id
    @item.spot_id      = @spot.id
    @item.published_at = Core.now
    
    @item.set_embedded_file_option :image1_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    @item.set_embedded_file_option :image2_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    @item.set_embedded_file_option :image3_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    
    return unless request.post?
      
    if @use_captcha
      return false unless @item.save_with_captcha
    else
      return false unless @item.save
    end
    
    redirect_to ::File.dirname(request.request_uri) + "/sent.html"
  end
  
  def sent
    
  end
end
