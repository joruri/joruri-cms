# encoding: utf-8
class Article::Admin::Doc::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    simple_layout

    @parent  = params[:parent]
    @tmp     = true if @parent.size == 32
    @content = Article::Content::Doc.find_by(id: params[:content]) if params[:content]

    return http_error(404) if @content.nil? || @content.model != 'Article::Doc'
  end

  def index
    @item = Sys::File.new

    @items = if @tmp
               Sys::File.where(tmp_id: @parent)
                        .where(parent_unid: nil)
             else
               Sys::File.where(tmp_id: nil)
                        .where(parent_unid: @parent)
             end

    @items = @items.order(:name)
                   .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::File.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Sys::File.new(
      in_resize_size: @content.setting_value(:attachment_resize_size),
      in_thumbnail_size: @content.setting_value(:attachment_thumbnail_size)
    )

    #    if @tmp
    #      @item.tmp_id = @parent
    #      @item.parent_unid = nil
    #    else
    #      @item.tmp_id = nil
    #      @item.parent_unid = @parent
    #    end
  end

  def create
    @item = Sys::File.new(files_params)

    if @tmp
      @item.tmp_id = @parent
    else
      @item.parent_unid = @parent
    end

    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    @item.use_resize @item.in_resize_size
    @item.use_thumbnail @content.setting_value(:attachment_thumbnail_size)

    _create @item
  end

  def update
    @item = Sys::File.find(params[:id])
    @item.attributes = files_params
    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    @item.skip_upload
    _update @item
  end

  def destroy
    @item = Sys::File.find(params[:id])
    _destroy @item
  end

  def download
    if @tmp
      items = Sys::File.where(tmp_id: @parent)
                       .where(parent_unid: nil)
    else
      items = Sys::File.where(tmp_id: nil)
                       .where(parent_unid: @parent)
    end

    if params[:id]
      items = items.where(id: params[:id])
    elsif params[:name] && params[:format]
      items = items.where(name: "#{params[:name]}.#{params[:format]}")
    end

    return http_error(404) unless @file = items.first

    file_path = @file.upload_path
    file_path = @file.upload_path(type: :thumb) if params[:thumb]

    send_storage_file file_path, type: @file.mime_type, filename: @file.name
  end

  def preview
    return http_error(404) if params[:path].blank?
    params[:thumb] = true if params[:path] =~ /\/thumb\//
    params[:name]  = ::File.basename(params[:path])
    download
  end

  private

  def files_params
    params.require(:item).permit(
      :file, :in_resize_size, :name, :title
    )
  end
end
