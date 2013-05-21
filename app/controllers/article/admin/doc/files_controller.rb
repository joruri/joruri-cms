# encoding: utf-8
class Article::Admin::Doc::FilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    simple_layout
    
    @parent  = params[:parent]
    @tmp     = true if @parent.size == 32
    @content = Article::Content::Doc.find_by_id(params[:content]) if params[:content]
    
    return http_error(404) if @content.nil? || @content.model != 'Article::Doc'
  end
  
  def index
    @item = Sys::File.new#.readable
    if @tmp
      @item.and :tmp_id, @parent
      @item.and :parent_unid, 'IS', nil
    else
      @item.and :tmp_id, 'IS', nil
      @item.and :parent_unid, @parent
    end
    @item.page  params[:page], params[:limit]
    @item.order params[:sort], :name
    @items = @item.find(:all)
    
    _index @items
  end
  
  def show
    @item = Sys::File.new.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Sys::File.new({
      :in_resize_size    => @content.setting_value(:attachment_resize_size),
      :in_thumbnail_size => @content.setting_value(:attachment_thumbnail_size),
    })
    if @tmp
      @item.and :tmp_id, @parent
      @item.and :parent_unid, 'IS', nil
    else
      @item.and :tmp_id, 'IS', nil
      @item.and :parent_unid, @parent
    end
  end
  
  def create
    @item = Sys::File.new(params[:item])
    if @tmp
      @item.tmp_id      = @parent
    else
      @item.parent_unid = @parent
    end
    
    @item.allowed_type  = @content.setting_value(:allowed_attachment_type)
    @item.use_resize @item.in_resize_size
    @item.use_thumbnail @content.setting_value(:attachment_thumbnail_size)
    
    _create @item
  end
  
  def update
    @item = Sys::File.new.find(params[:id])
    @item.attributes   = params[:item]
    @item.allowed_type = @content.setting_value(:allowed_attachment_type)
    @item.skip_upload
    _update @item
  end
  
  def destroy
    @item = Sys::File.new.find(params[:id])
    _destroy @item
  end
  
  def download
    item = Sys::File.new
    if @tmp
      item.and :tmp_id, @parent
      item.and :parent_unid, 'IS', nil
    else
      item.and :tmp_id, 'IS', nil
      item.and :parent_unid, @parent
    end
    if params[:id]
      item.and :id, params[:id]
    elsif params[:name] && params[:format]
      item.and :name, "#{params[:name]}.#{params[:format]}"
    end
    return http_error(404) unless @file = item.find(:first)
    
    file_path = @file.upload_path
    
    if params[:thumb]
      file_path = @file.upload_path(:type => :thumb)
    end
    
    send_storage_file file_path, :type => @file.mime_type, :filename => @file.name
  end
  
  def preview
    return http_error(404) if params[:path].blank?
    params[:thumb] = true if params[:path] =~ /\/thumb\//
    params[:name]  = ::File.basename(params[:path])
    download
  end
end
