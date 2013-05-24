# encoding: utf-8
class Sys::Admin::StorageFilesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  before_filter :validate_path
  
  @root  = nil
  @roots = []
  @navi  = []
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    
    sites   = Cms::Site.find(:all, :order => :id)
    @roots  = []
    @roots += sites.collect{|c| [::File.basename(c.public_path), ::File.basename(c.public_path)] }
    @roots << ["public", "public"]
    @roots << ["upload", "upload"]
  end
  
  def validate_path
    @path = ::File.join(Rails.root.to_s, params[:path].to_s)
    #return http_error(404) if params[:path] && !::Storage.exists?(@path)
    
    @dir = params[:path]
    @roots.each do |dir, path|
      if @dir.to_s =~ /^#{Regexp.escape(dir)}(\/|$)/
        @root = dir
        break
      end
    end
    
    if !@root
      @root = @roots.first[1]
      @path = ::File.join(@path, @root)
      @dir  = @root
    end
    
    @navi = []
    dirs = @dir.split(/\//)
    dirs.each_with_index do |n, idx|
      next if idx == 0
      @navi << [n, dirs.slice(0, idx + 1).join("/")]
    end
    
    @do          = params[:do].blank? ? nil : params[:do]
    @is_dir      = ::Storage.directory?(@path)
    @is_file     = ::Storage.file?(@path)
    @current_uri = sys_storage_files_path(@dir).gsub(/\?.*/, '')
    @parent_uri  = sys_storage_files_path(:path => ::File.dirname(@dir)).gsub(/\?.*/, '')
  end
  
  def index
    if @do == "show"
      return http_error(404) if !::Storage.exists?(@path)
      return show_dir if @is_dir
      return show_file if @is_file
    elsif @do == "download"
      return send_data(::Storage.read(@path), :content_type => ::Storage.mime_type(@path), :disposition => :attachment)
    elsif @do == "edit"
      return edit_file
    elsif @do == "rename"
      return rename
    elsif @do == "destroy"
      return destroy
    elsif @is_file
      return show_file
    end
    
    @dirs  = []
    @files = []
    files  = ::Storage.entries(@path)
    files.each {|name| @dirs << name if ::Storage.directory?("#{@path}/#{name}")}
    files.each {|name| @files << name if ::Storage.file?("#{@path}/#{name}")}
    
    @items = @dirs.sort + @files.sort
    
    _index @items
  end
  
  def show_dir
    @item = {
      :name      => ::File.basename(@path),
    }
    render :action => :show_dir
  end

  def show_file
    body = nil
    if body = ::Storage.read(@path)
      body = NKF.nkf('-w', body) if body.is_a?(String)
      body = body.force_encoding("utf-8") if body.respond_to?(:force_encoding)
    end
    
    @item = {
      :name      => ::File.basename(@path),
      :mtime     => ::Storage.mtime(@path),
      :size      => ::Storage.kb_size(@path),
      :mime_type => ::Storage.mime_type(@path),
      :body      => body,
    }
    render :action => :show_file
  end

  def edit_file
    body = nil
    if body = ::Storage.read(@path)
      body = NKF.nkf('-w', body) if body.is_a?(String)
      body = body.force_encoding("utf-8") if body.respond_to?(:force_encoding)
    end
    
    @item = {
      :name      => ::File.basename(@path),
      :mtime     => ::Storage.mtime(@path),
      :size      => ::Storage.kb_size(@path),
      :mime_type => ::Storage.mime_type(@path),
      :body      => body,
    }
    render :action => :edit_file
  end
  
  def new
    exit
  end
  
  def create
    return update if params[:do] == "update"
    
    if params[:create_directory]
      if name = validate_name(params[:item][:new_directory])
        if ::Storage.exists?("#{@path}/#{name}")
          flash[:notice] = "ディレクトリは既に存在します。"
        else
          ::Storage.mkdir("#{@path}/#{name}")
          flash[:notice] = "ディレクトリを作成しました。"
        end
        return redirect_to(@current_uri)
      end
      
    elsif params[:create_file]
      if name = validate_name(params[:item][:new_file])
        if ::Storage.exists?("#{@path}/#{name}")
          flash[:notice] = "ファイルは既に存在します。"
        else
          ::Storage.write("#{@path}/#{name}", "")
          flash[:notice] = "ファイルを作成しました。"
        end
        return redirect_to("#{@current_uri}/#{name}?do=show")
      end
      
    elsif params[:upload_file] && file = params[:item][:new_upload]
      
      if name = validate_name(file.original_filename)
        ::Storage.binwrite("#{@path}/#{name}", file.read)
        flash[:notice] = "アップロードが完了しました。"
        return redirect_to(@current_uri)
      end
    end
    
    redirect_to @current_uri
  end
  
  def update
    if ::Storage.write(@path, params[:body])
      flash[:notice] = "更新処理が完了しました。"
    else
      flash[:notice] = "更新処理に失敗しました。"
    end
    
    return redirect_to(@parent_uri)
  end
  
  def destroy
    if ::Storage.rm_rf(@path)
      flash[:notice] = "削除処理が完了しました。"
    else
      flash[:notice] = "削除処理に失敗しました。"
    end
    
    redirect_to @parent_uri
  end
  
protected
  
  def validate_name(name)
    if name.to_s !~ /^[0-9A-Za-z@\.\-\_]+$/
      return nil
    end
    return name
  end
end
