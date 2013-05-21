# encoding: utf-8
class Tourism::Admin::SpotsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Cms::EmbeddedFileHelper
  helper Tourism::FormHelper

  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    item = Tourism::Spot.new#.public#.readable
    #item.public unless Core.user.has_auth?(:manager)
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Tourism::Spot.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Tourism::Spot.new({
      :content_id   => @content.id,
      :state        => 'public',
    })
  end
  
  def create
    @item = Tourism::Spot.new(params[:item])
    @item.content_id = @content.id
    
    @item.set_embedded_file_option :image_file_id,
      :resize    => @content.setting_value(:spot_resize_size),
      :thumbnail => @content.setting_value(:spot_thumbnail_size)
    @item.set_embedded_file_option :detail_image1_file_id,
      :thumbnail => @content.setting_value(:spot_detail_thumbnail_size)
    @item.set_embedded_file_option :detail_image2_file_id,
      :thumbnail => @content.setting_value(:spot_detail_thumbnail_size)
    @item.set_embedded_file_option :detail_image3_file_id,
      :thumbnail => @content.setting_value(:spot_detail_thumbnail_size)
    
    _create @item
  end

  def update
    @item = Tourism::Spot.new.find(params[:id])
    @item.attributes = params[:item]

    @item.set_embedded_file_option :image_file_id,
      :resize    => @content.setting_value(:spot_resize_size),
      :thumbnail => @content.setting_value(:spot_thumbnail_size)
    @item.set_embedded_file_option :detail_image1_file_id,
      :thumbnail => @content.setting_value(:spot_detail_thumbnail_size)
    @item.set_embedded_file_option :detail_image2_file_id,
      :thumbnail => @content.setting_value(:spot_detail_thumbnail_size)
    @item.set_embedded_file_option :detail_image3_file_id,
      :thumbnail => @content.setting_value(:spot_detail_thumbnail_size)
    
    _update(@item)
  end
  
  def destroy
    @item = Tourism::Spot.new.find(params[:id])
    _destroy @item
  end
end
