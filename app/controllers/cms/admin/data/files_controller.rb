# encoding: utf-8
class Cms::Admin::Data::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to :action => 'index' if params[:reset]
    
    if params[:parent] && params[:parent] != '0'
      @parent = Cms::DataFileNode.find(params[:parent])
    else
      @parent = Cms::DataFileNode.new
      @parent.id = 0
    end
  end

  def index
    @nodes = Cms::DataFileNode.find(:all, :conditions => {:concept_id => Core.concept(:id)}, :order => :name)
    
    item = Cms::DataFile.new
    item.readable if params[:s_target] != "all"
    #item.and 'node_id', @parent.id if @parent.id != 0
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'name, id'
    @items = item.find(:all)
    _index @items
  end

  def show
    item = Cms::DataFile.new.readable
    @item = item.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::DataFile.new({
      :concept_id => Core.concept(:id),
      :state      => 'public'
    })
  end

  def create
    @item = Cms::DataFile.new(params[:item])
    @item.site_id = Core.site.id
    @item.state   = 'public'
    @item.use_resize(@item.in_resize_size.blank? ? false : @item.in_resize_size)
    
    _create @item
  end

  def update
    @item = Cms::DataFile.new.find(params[:id])
    @item.attributes = params[:item]
    @item.node_id    = nil if @item.concept_id_changed?
    @item.use_resize(@item.in_resize_size.blank? ? false : @item.in_resize_size)
    
    @item.skip_upload if @item.file.blank?
    _update @item
  end

  def destroy
    @item = Cms::DataFile.new.find(params[:id])
    _destroy @item
  end

  def download
    item = Cms::DataFile.new.readable
    item.and :id, params[:id]
    return error_auth unless @file = item.find(:first)
    
    send_storage_file @file.upload_path, :type => @file.mime_type, :filename => @file.name
  end
  
  def thumbnail
    item = Cms::DataFile.new.readable
    item.and :id, params[:id]
    return error_auth unless @file = item.find(:first)
    
    upload_path = @file.upload_path
    thumb_path  = ::File.dirname(@file.upload_path) + "/thumb.dat"
    upload_path = thumb_path if ::Storage.exists?(thumb_path)
    
    send_storage_file upload_path, :type => @file.mime_type, :filename => @file.name
  end
end
