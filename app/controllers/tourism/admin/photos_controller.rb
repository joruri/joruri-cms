# encoding: utf-8
class Tourism::Admin::PhotosController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Cms::EmbeddedFileHelper
  helper Tourism::FormHelper

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item = Tourism::Photo.new(params.reject { |k, _v| k.to_s !~ /^s_/ })

    @items = Tourism::Photo
             .where(content_id: @content)
             .search(params)
             .order(params[:sort] || updated_at: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Tourism::Photo.find(params[:id])
    _show @item
  end

  def new
    @item = Tourism::Photo.new(state: 'public',
                               content_id: @content.id)
  end

  def create
    @item = Tourism::Photo.new(params[:item])
    @item.content_id = @content.id

    @item.set_embedded_file_option :image_file_id,
                                   resize: @content.setting_value(:photo_resize_size),
                                   thumbnail: @content.setting_value(:photo_thumbnail_size)

    _create @item
  end

  def update
    @item = Tourism::Photo.find(params[:id])
    @item.attributes = params[:item]

    @item.set_embedded_file_option :image_file_id,
                                   resize: @content.setting_value(:photo_resize_size),
                                   thumbnail: @content.setting_value(:photo_thumbnail_size)

    _update @item
  end

  def destroy
    @item = Tourism::Photo.find(params[:id])
    _destroy @item
  end
end
