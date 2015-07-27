# encoding: utf-8
class Cms::Admin::StylesheetsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  @@mkdir_root = nil
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    
    if !@@mkdir_root
      dir = Cms::Stylesheet.new_by_path("").upload_path
      ::Storage.mkdir_p(dir) if !::Storage.exists?(dir)
      @@mkdir_root = true
    end
    
    @root      = "#{Rails.root}/public/_common/themes"
    @path      = params[:path].to_s
    @full_path = "#{@root}/#{@path}"
    @base_uri  = ["#{Rails.root}/public", "/"]
    @item      = Cms::Stylesheet.new_by_path(@path)
    
    if !::Storage.exists?(@item.upload_path)
      return http_error(404) if flash[:notice]
      flash[:notice] = "指定されたパスは存在しません。（ #{@item.upload_path} ）"
      redirect_to(cms_stylesheets_path(''))
    end
    
    @stylesheets_path = lambda do |path, options = {}|
      options = {:path => path, :concept => Core.concept.id}.merge(options)
      cms_stylesheets_path(options).gsub('//', '/')
    end
  
    @stylesheet_path = lambda do |path, options = {}|
      options = {:path => path, :concept => Core.concept.id, :do => :show}.merge(options)
      cms_stylesheets_path(options).gsub('//', '/')
    end
  end
  
  def index
    return show    if params[:do] == 'show'
    return edit    if params[:do] == 'edit'
    return update  if params[:do] == 'update'
    return rename  if params[:do] == 'rename'
    return move    if params[:do] == 'move'
    return destroy if params[:do] == 'destroy'
    
    if params[:do] == 'download'
      return send_data(::Storage.read(@full_path), :content_type => ::Storage.mime_type(@full_path), :disposition => :attachment)
    end
    
    if params[:do].nil? && !@item.directory?
      params[:do] = "show"
      return show
    elsif request.post? && location = create
      return error_auth unless @item.creatable?
      return redirect_to(location)
    end
    
    @dirs  = @item.child_directories
    @files = @item.child_files
  end
  
  def show
    #return error_auth unless @item.readable?
    
    @item.read_body
    render :action => :show
  end
  
  def edit
    return error_auth unless @item.editable?

    @item.read_body
    render :action => :edit
  end
  
  def create

    if params[:create_directory]
      if @item.create_directory(params[:item][:new_directory])
        flash[:notice] = 'ディレクトリを作成しました。'
        return @stylesheets_path.call(@path)
      end
    elsif params[:create_file]
      if @item.create_file(params[:item][:new_file])
        flash[:notice] = 'ファイルを作成しました。'
        return @stylesheets_path.call(::File.join(@path, params[:item][:new_file]), :do => 'edit')
      end
    elsif params[:upload_file]
      if @item.upload_file(params[:item][:new_upload])
        flash[:notice] = 'アップロードが完了しました。'
        return @stylesheets_path.call(@path)
      end
    end
    return false
  end
  
  def update
    return error_auth unless @item.editable?

    old_path = @item.upload_path
    
    if @item.directory?
      @item.concept_id = params[:item][:concept_id]
      @item.site_id    = Core.site.id if @item.concept_id
    else 
      @item.body = params[:item][:body] if params[:item].has_key?(:body)
    end
    
    if !@item.valid? || !@item.update_item
      flash[:notice] = '更新処理に失敗しました。'
      return render(:action => :edit)
    end
    
    if @item.name != params[:item][:name] && !@item.rename(params[:item][:name])
      flash[:notice] = '更新処理に失敗しました。'
      return render(:action => :edit)
    end
      
    flash[:notice] = '更新処理が完了しました。'
    location = @stylesheets_path.call(::File.dirname(@path))
    return redirect_to(location)
  end
  
  def move
    return error_auth unless @item.editable?
    
    if request.put?
      if @item.move(params[:item][:path])
        flash[:notice] = '移動処理が完了しました。'
        location = @stylesheets_path.call(::File.dirname(@path))
        return redirect_to(location)
      end
    end
    
    render :action => :move
  end
  
  def destroy
    return error_auth unless @item.deletable?
    
    if @item.destroy
      flash[:notice] = "削除処理が完了しました。"
    else
      flash[:notice] = "削除処理に失敗しました。（#{@item.errors.full_messages.join(' ')}）"
    end
    location = @stylesheets_path.call(::File.dirname(@path))
    return redirect_to(location)
  end
end
