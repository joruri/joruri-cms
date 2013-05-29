# encoding: utf-8
require 'mime/types'
require 'nkf'

class Cms::Stylesheet < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Auth::Concept
  
  attr_accessor :name, :body, :base_path, :base_uri
  attr_accessor :new_directory, :new_file, :new_upload
  
  validates_presence_of :name
  validates_format_of :name, :with=> /^[0-9A-Za-z@\.\-\_]+$/, :message=> :not_a_filename
  
  after_destroy :remove_file
  
  def self.new_by_path(path)
    item = self.find_by_path(path) || self.new(:path => path)
    item.base_path = "#{Rails.root}/public/_common/themes"
    item.base_uri  = "/_common/themes/"
    item.name      = ::File.basename(path)
    #item.new_record = params[:new_record] ? true : false
    return item
  end
  
  def concept(reload = nil)
    return @_concept if @_concept && !reload
    return @_concept = Cms::Concept.find_by_id(concept_id) if concept_id
    
    dir = ::File.dirname(path)
    return @_concept = nil if !dir.blank? && dir =~ /^(\.+|\/)$/
    
    parent = self.class.new_by_path(dir)
    @_concept = parent ? parent.concept : nil
  end
  
  def upload_path
    ::File.join(base_path, path)
  end
  
  # def public_path
    # ::File.join(base_uri, path)
  # end
  
  def public_uri
    ::File.join(base_uri, path)
  end
  
  def directory?
    ::Storage.directory?(upload_path)
  end
  
  def file?
    ::Storage.file?(upload_path)
  end
  
  def textfile?
    return false unless file?
    mime_type.blank? || mime_type =~ /(text|javascript)/i
  end
  
  def read_body
    begin
      self.body = false
      self.body = NKF.nkf('-w', ::Storage.read(upload_path).to_s) if textfile?
    rescue => e
      # #読み込み失敗
    end
  end
  
  def mtime
    ::Storage.mtime(upload_path)
  end
  
  def mime_type
    @_mime_type ||= ::Storage.mime_type(upload_path)
    @_mime_type
  end
  
  def type
    return 'text' if mime_type == "text/plain"
    mime_type.gsub(/.*\//, '')
  end
  
  def size(unit = nil)
    size = ::Storage.size(upload_path)
    if unit == :kb
      (size.to_f/1024).ceil
    else
      size
    end
  end
  
  def child_directories
    items = []
    ::Storage.entries(upload_path).sort.each do |name|
      next if name =~ /^\.+/
      child_path = ::File.join(upload_path, name)
      next if ::Storage.file?(child_path)
      cpath = path.blank? ? name : ::File.join(path, name)
      items << self.class.new_by_path(cpath)
    end
    items
  end
  
  def child_files
    items = []
    ::Storage::entries(upload_path).sort.each do |name|
      next if name =~ /^\.+/
      child_path = ::File.join(upload_path, name)
      next if ::Storage.directory?(child_path)
      cpath = path.blank? ? name : ::File.join(path, name)
      items << self.class.new_by_path(cpath)
    end
    items
  end
  
  ## Validation
  def valid_filename?(name, value)
    if value.blank?
      errors.add name, :empty
    elsif value !~ /^[0-9A-Za-z@\.\-\_]+$/
      errors.add name, :not_a_filename
    elsif value =~ /^[\.]+$/
      errors.add name, :not_a_filename
    end
    return errors.size == 0
  end
  
  def valid_path?(name, value)
    if value.blank?
      errors.add name, :empty
    elsif value !~ /^[0-9A-Za-z@\.\-\_\/]+$/
      errors.add name, :not_a_filename
    elsif value =~ /(^|\/)\.+(\/|$)/
      errors.add name, :not_a_filename
    end
    return errors.size == 0
  end
  
  def valid_exists?(path, type = nil)
    return true unless ::Storage.exists?(path)
    if type == nil
      errors.add :base, "ファイルが既に存在します。"
    elsif type == :file
      errors.add :base, "ファイルが既に存在します。" if ::Storage.file?(path)
    elsif type == :directory
      errors.add :base, "ディレクトリが既に存在します。" if ::Storage.file?(path)
    end
    return errors.size == 0
  end
  
  def create_directory(name)
    @new_directory = name.to_s
    return false unless valid_filename?(:new_directory, @new_directory)
    
    src = ::File::join(upload_path, @new_directory)
    return false unless valid_exists?(src)
    
    ::Storage.mkdir(src)
  rescue => e
    errors.add :base, (e.to_s)
    return false
  end
  
  def create_file(name)
    @new_file = name.to_s
    return false unless valid_filename?(:new_file, @new_file)
    
    src = ::File::join(upload_path, @new_file)
    return false unless valid_exists?(src)
    
    ::Storage.touch(src)
  rescue => e
    errors.add :base, e.to_s
    return false
  end
  
  def upload_file(file)
    unless file
      errors.add :new_upload, :empty
      return false
    end
    
    src = ::File::join(upload_path, file.original_filename)
    if ::Storage.exists?(src) && ::Storage.directory?(src)
      errors.add :base, "同名のディレクトリが既に存在します。"
      return false
    end
    
    ::Storage.binwrite(src, file.read)
    return true
  rescue => e
    errors.add :base, e.to_s
    return false
  end
  
  def update_item
    if ::Storage.file?(upload_path)
      ::Storage.write(upload_path, self.body)
    else
      save
    end
    return true
  rescue => e
    errors.add :base, e.to_s
    return false
  end
  
  def rename(name)
    @new_name = name.to_s
    return false unless valid_filename?(:name, @new_name)
    
    src = upload_path
    dst = ::File::join(::File.dirname(upload_path), @new_name)
    
    is_dir = directory?
    ::Storage.mv(src, dst) if src != dst
    
    self.path = ::File.join(::File.dirname(path), @new_name).gsub(/^\.\//, '')
    
    return false if is_dir && !save
    
    return true
  rescue => e
    errors.add :base, e.to_s
    return false
  end
  
  def move(new_path)
    @new_path = new_path.to_s.gsub(/\/+/, '/')
    
    return false unless valid_path?(:path, @new_path)
    
    src = upload_path
    dst = ::File::join(base_path, @new_path)
    return true if src == dst
    
    if !::Storage.exists?(::File.dirname(dst))
      errors.add :base, "ディレクトリが見つかりません。（ #{::File.dirname(dst)} ）"
    elsif src == ::File.dirname(dst)
      errors.add :base, "ディレクトリが見つかりません。（ #{src} ）"
    end
    return false if errors.size != 0
    return false unless valid_exists?(dst, :file)
    
    is_dir = directory?
    ::Storage.mv(src, dst)
    
    self.path = @new_path
    return false if is_dir && !save
    
    return true
  rescue => e
    if e.to_s =~ /^same file/i
      return true
    elsif e.to_s =~ /^Not a directory/i
      errors.add :base, "ディレクトリが見つかりません。（ #{dst} ）"
    else
      errors.add :base, e.to_s
    end
    return false
  end
  
protected

  def remove_file
    is_dir = directory?
    ::Storage.rm_rf(upload_path)
    self.class.destroy_all(["site_id = ? AND path LIKE ?", site_id, path.to_s.gsub(/\/$/, '') + "/%"]) if is_dir
    return true
  rescue => e
    errors.add :base, e.to_s
    return false
  end
  
  # def escaped_path
    # URI.escape(path)
  # end
end