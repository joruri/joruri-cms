# encoding: utf-8
module Sys::Model::Base::File
  def self.included(mod)
    mod.validates_presence_of :file, :if => "@_skip_upload != true"
    mod.validates_presence_of :name, :title
    mod.validate :validate_file_name
    mod.validate :validate_file_type
    mod.validate :validate_upload_file
    mod.after_save :upload_internal_file
    mod.after_destroy :remove_internal_file
  end
  
  def self.sizes(options = {})
    sizes = []
    sizes << ["#{options[:include_blank]}", ""] if options.has_key?(:include_blank)
    sizes << ["640x480 (VGA)"   , "640x480"]
    sizes << ["480x640 (VGA)"   , "480x640"]
    sizes << ["800x600 (SVGA)"  , "800x600"]
    sizes << ["600x800 (SVGA)"  , "600x800"]
    sizes << ["1600x1200 (UXGA)", "1600x1200"]
    sizes << ["1200x1600 (UXGA)", "1200x1600"]
    sizes << ["1280x720 (HD)"   , "1280x720"]
    sizes << ["720x1280 (HD)"   , "720x1280"]
    sizes << ["1600x900 (HD+)"  , "1600x900"]
    sizes << ["900x1600 (HD+)"  , "900x1600"]
    sizes << ["1920x1080 (FHD)" , "1920x1080"]
    sizes << ["1080x1920 (FHD)" , "1080x1920"]
    sizes
  end
  
  @@_maxsize = 50# MegaBytes
  @@_resize_size = { :width => 640, :height => 480 }
  @@_thumbnail_size = { :width => 120, :height => 90 }
  
  attr_accessor :file, :allowed_type
  
  def skip_upload(bool = true)
    @_skip_upload = bool
  end
  
  def resize_size
    return nil if @resize_size == false
    @resize_size ? @resize_size : @@_resize_size
  end
  
  def use_resize(width_or_size, height = nil)
    if width_or_size == false
      return @resize_size = false
    elsif width_or_size.blank?
      return @resize_size = false
    end
    
    if height
      width  = width_or_size.to_i
      height = height.to_i
    elsif width_or_size.to_s.index('x')
      size   = width_or_size.to_s.split('x')
      width  = size[0].to_i
      height = size[1].to_i
    else
      width  = width_or_size.to_i
      height = width
    end
    
    @resize_size = { :width => width, :height => height }
  end
  
  def has_thumbnail?
    thumb_width.nil? ? false : true
  end
  
  def thumbnail_size
    return nil if @thumbnail_size == false
    @thumbnail_size ? @thumbnail_size : @@_thumbnail_size
  end
  
  def use_thumbnail(width_or_size, height = nil)
    if width_or_size == false
      return @thumbnail_size = false
    elsif width_or_size.blank?
      return @thumbnail_size = nil
    end
    
    if height
      width  = width_or_size.to_i
      height = height.to_i
    elsif width_or_size.to_s.index('x')
      size   = width_or_size.to_s.split('x')
      width  = size[0].to_i
      height = size[1].to_i
    else
      width  = width_or_size.to_i
      height = width
    end
    
    @thumbnail_size = { :width => width, :height => height }
  end
  
  def validate_file_name
    return true if name.blank?
    
    if self.name !~ /^[0-9a-zA-Z\-\_\.]+$/
      errors.add :name, "は半角英数字を入力してください。"
    elsif self.name.count('.') != 1
      errors.add(:name, 'を正しく入力してください。＜ファイル名.拡張子＞')
    elsif duplicated?
      errors.add :name, "は既に存在しています。"
      return false
    end
    self.title = self.name if title.blank?
  end
  
  def validate_file_type
    return true if allowed_type.blank?
    
    types = {}
    allowed_type.to_s.split(/ *, */).each do |m|
      m = ".#{m.gsub(/ /, '').downcase}"
      types[m] = true if !m.blank?
    end
    
    if !name.blank?
      ext = ::File.extname(name.to_s).downcase
      if types[ext] != true
        errors.add :base, "許可されていないファイルです。（#{allowed_type}）"
        return
      end
    end
    
    if !file.blank? && !file.original_filename.blank?
      ext = ::File.extname(file.original_filename.to_s).downcase
      if types[ext] != true
        errors.add :base, "許可されていないファイルです。（#{allowed_type}）"
        return
      end
    end
  end
  
  def validate_upload_file
    return true if file.blank?
    
    maxsize = @maxsize || @@_maxsize
    if file.size > maxsize.to_i  * (1024**2)
      errors.add :file, "が容量制限を超えています。＜#{maxsize}MB＞"
      return true
    end
    
    self.mime_type    = file.content_type
    self.size         = file.size
    self.image_is     = 2
    self.image_width  = nil
    self.image_height = nil
    self.thumb_width  = nil
    self.thumb_height = nil
    
    @_file_data = file.read
    
    if name =~ /\.(bmp|gif|jpg|jpeg|png)$/i
      begin
        require 'RMagick'
        image = Magick::Image.from_blob(@_file_data).shift
        if image.format =~ /(GIF|JPEG|PNG)/
          self.image_is = 1
          self.image_width  = image.columns
          self.image_height = image.rows
          
          if size = resize_size
            if image_width > size[:width] || image_height > size[:height]
              @resized_image  = image.resize_to_fit(size[:width], size[:height])
              self.image_width  = @resized_image.columns
              self.image_height = @resized_image.rows
              self.size         = @resized_image.to_blob.size
            end
          end
          
          if size = thumbnail_size
            size = @@_thumbnail_size if size[:width] > 640 || size[:height] > 480
            @thumbnail_image  = image.resize_to_fit(size[:width], size[:height])
            self.thumb_width  = size[:width]
            self.thumb_height = size[:height]
            self.thumb_size   = @thumbnail_image.to_blob.size
          end
        end
      rescue LoadError
      rescue Magick::ImageMagickError
      rescue NoMethodError
      end
    end
  end
  
  def upload_path(options = {})
    md_dir  = "#{self.class.to_s.underscore.pluralize}"
    id_dir  = format('%08d', id).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    id_file = format('%07d', id) + '.dat'
    
    if options[:type]
      id_file = "#{options[:type]}.dat"
    end
    
    "#{Rails.root}/upload/#{md_dir}/#{id_dir}/#{id_file}"
  end
  
  def readable
    return self
  end

  def editable
    return self
  end

  def deletable
    return self
  end
  
  def readable?
    return true
  end
  
  def creatable?
    return true
  end
  
  def editable?
    return true
  end
  
  def deletable?
    return true
  end
  
  def image_file?
    image_is == 1 ? true : nil 
  end
  
  def escaped_name
    CGI::escape(name)
  end
  
  def united_name
    title + '(' + eng_unit + ')'
  end
  
  def alt
    title.blank? ? name : title
  end
  
  def image_size
    return '' unless image_file?
    "(#{image_width}x#{image_height})"
  end
  
  def duplicated?
    nil
  end
  
  def css_class
    if ext = File::extname(name).downcase[1..5]
      conv = {
        'docx' => 'doc',
        'xlsx' => 'xls',
      }
      ext = conv[ext] if conv[ext]
      ext = ext.gsub(/[^0-9a-z]/, '')
      return 'iconFile icon' + ext.gsub(/\b\w/) {|word| word.upcase}
    end
    return 'iconFile'
  end
  
  def eng_unit
    _size = size
    return _size if _size.to_s !~ /^[0-9]+$/
    
    if _size >= 1024**3
      bs = (_size.to_f / (1024**3)).round#.to_s + '000'
      return "#{bs}GB"
    elsif _size >= 1024**2
      bs = (_size.to_f / (1024**2)).round#.to_s + '000'
      return "#{bs}MB"
    elsif _size >= 1000
      bs = (_size.to_f / 1024).round#.to_s + '000'
      return "#{bs}KB"
    end
    return "#{_size}Bytes"
  end
  
  def reduce_size(options = {})
    return nil unless image_file?
    
    src_w  = image_width.to_f
    src_h  = image_height.to_f
    dst_w  = options[:width].to_f
    dst_h  = options[:height].to_f
    src_r    = (src_w / src_h)
    dst_r    = (dst_w / dst_h)
    if dst_r > src_r
      dst_w = (dst_h * src_r);
    else
      dst_h = (dst_w / src_r);
    end

    if options[:css]
      return "width: #{dst_w.ceil}px; height:#{dst_h.ceil}px;"
    end
    return {:width => dst_w.ceil, :height => dst_h.ceil}
  end
  
  def mobile_image(mobile, params = {})
    return nil unless mobile
    return nil if mobile.smart_phone?
    return nil if image_is != 1
    return nil if image_width <= 300 && image_height <= 400
    
    begin
      require 'RMagick'
      #info = Magick::Image::Info.new
      size = reduce_size(:width => 300, :height => 400)
      img  = Magick::Image.read(params[:path]).first
      img  = img.resize(size[:width], size[:height])
      
      case mobile
      when Jpmobile::Mobile::Docomo
        img.format = 'JPEG' if img.format == 'PNG'
      when Jpmobile::Mobile::Au
        img.format = 'PNG' if img.format == 'JPEG'
        img.format = 'GIF'
      when Jpmobile::Mobile::Softbank
        img.format = 'JPEG' if img.format == 'GIF'
      end
    rescue
      return nil
    end
    return img
  end
  
private
  ## filter/aftar_save
  def upload_internal_file
    return true if @_file_data == nil
    
    org_path   = ::File.dirname(upload_path) + "/original.dat"
    thumb_path = ::File.dirname(upload_path) + "/thumb.dat"
    
    if @resized_image
      ::Storage.mkdir_p(::File.dirname(upload_path))
      ::Storage.binwrite(upload_path, @resized_image.to_blob)
      ::Storage.mkdir_p(::File.dirname(org_path))
      ::Storage.binwrite(org_path, @_file_data)
    else
      ::Storage.mkdir_p(::File.dirname(upload_path))
      ::Storage.binwrite(upload_path, @_file_data)
      ::Storage.rm_rf(org_path) if ::Storage.exists?(org_path)
    end
    
    if @thumbnail_image
      ::Storage.binwrite(thumb_path, @thumbnail_image.to_blob)
    else
      ::Storage.rm_rf(thumb_path) if ::Storage.exists?(thumb_path)
    end
    
    return true
  end
  
  ## filter/aftar_destroy
  def remove_internal_file
    ::Storage.rm_rf(upload_path) if ::Storage.exists?(upload_path)
    
    dir  = ::File.dirname(upload_path)
    
    path = "#{dir}/original.dat"
    ::Storage.rm_rf(path) if ::Storage.exists?(path)
    
    path = "#{dir}/thumb.dat"
    ::Storage.rm_rf(path) if ::Storage.exists?(path)
    
    ::Storage.rmdir(dir) rescue nil
    
    return true
  end
end