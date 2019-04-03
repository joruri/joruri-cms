# encoding: utf-8
class Cms::Admin::Data::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication
  include Sys::Lib::File::Transfer

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to action: 'index' if params[:reset]

    if params[:parent] && params[:parent] != '0'
      @parent = Cms::DataFileNode.find(params[:parent])
    else
      @parent = Cms::DataFileNode.new
      @parent.id = 0
    end
  end

  def index
    @nodes = Cms::DataFileNode.where(concept_id: Core.concept(:id)).order(:name)

    @items = Cms::DataFile.where(site_id: Core.site.id)
    @items = @items.readable if params[:s_target] != 'all'
    @items = @items.search(params)
                   .paginate(page: params[:page], per_page: params[:limit])
                   .order(:name, :id)

    _index @items
  end

  def show
    @item = Cms::DataFile.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::DataFile.new(concept_id: Core.concept(:id),
                              state: 'public')
  end

  def create
    @item = Cms::DataFile.new(files_params)
    @item.site_id = Core.site.id
    @item.state = 'public'
    @item.use_resize(@item.in_resize_size.blank? ? false : @item.in_resize_size)
    transfer_files() if transfer_to_publish?
    _create @item
  end

  def update
    @item = Cms::DataFile.find(params[:id])
    @item.attributes = files_params
    @item.node_id = nil if @item.concept_id_changed?
    @item.use_resize(@item.in_resize_size.blank? ? false : @item.in_resize_size)

    @item.skip_upload if @item.file.blank?
    transfer_files() if transfer_to_publish?
    _update @item
  end

  def destroy
    @item = Cms::DataFile.find(params[:id])
    transfer_files() if transfer_to_publish?
    _destroy @item
  end

  def download
    @file = Cms::DataFile
            .readable
            .where(id: params[:id])
            .first
    return error_auth unless @file

    send_storage_file @file.upload_path, type: @file.mime_type, filename: @file.name
  end

  def thumbnail
    @file = Cms::DataFile
            .readable
            .where(id: params[:id])
            .first
    return error_auth unless @file

    upload_path = @file.upload_path
    thumb_path  = ::File.dirname(@file.upload_path) + '/thumb.dat'
    upload_path = thumb_path if ::Storage.exists?(thumb_path)

    send_storage_file upload_path, type: @file.mime_type, filename: @file.name
  end

  private

  def files_params
    params.require(:item).permit(
      :concept_id, :state, :name, :node_id, :title, :body, :file,
      :in_resize_size, :parent
    )
  end
end
