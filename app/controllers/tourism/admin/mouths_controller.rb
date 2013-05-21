# encoding: utf-8
class Tourism::Admin::MouthsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Cms::EmbeddedFileHelper
  helper Tourism::FormHelper
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    #default_url_options[:content] = @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
  
  def index
    @item = Tourism::Mouth.new(params.reject{|k,v| k.to_s !~ /^s_/ }) # search
    
    item = Tourism::Mouth.new#.readable
    item.and :content_id, @content
    item.search params
    item.page  params[:page], params[:limit]
    item.order (params[:sort] || "updated_at DESC")
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Tourism::Mouth.new.find(params[:id])
    _show @item
  end

  def edit
    @item = Tourism::Mouth.new.find(params[:id])
    if @item.spot && @item.spot.genre_items.count > 0
      @item.genre    = @item.spot.genre_items[0]
      @item.genre_id = @item.genre.id
    end
  end
  
  def new
    @item = Tourism::Mouth.new({
      :state      => 'public',
      :content_id => @content.id,
    })
  end
  
  def create
    @item = Tourism::Mouth.new(params[:item])
    @item.content_id = @content.id
    
    @item.set_embedded_file_option :image1_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    @item.set_embedded_file_option :image2_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    @item.set_embedded_file_option :image3_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    
    _create @item
  end
  
  def update
    @item = Tourism::Mouth.new.find(params[:id])
    @item.attributes = params[:item]
    
    @item.set_embedded_file_option :image1_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    @item.set_embedded_file_option :image2_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    @item.set_embedded_file_option :image3_file_id,
      :resize    => @content.setting_value(:mouth_resize_size),
      :thumbnail => @content.setting_value(:mouth_thumbnail_size)
    
    _update @item
  end
  
  def destroy
    @item = Tourism::Mouth.new.find(params[:id])
    _destroy @item
  end
end
