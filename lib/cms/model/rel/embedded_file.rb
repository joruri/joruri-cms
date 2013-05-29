# encoding: utf-8
module Cms::Model::Rel::EmbeddedFile
  
  # * example
  # embed_file_of :field1, :field2
  # embed_file_of :field1 => { :resize => size, :thumbnail => size }
  
  def self.included(mod)
    mod.extend(ClassMethods)
    mod.cattr_accessor :embedded_file_names
    mod.cattr_accessor :embedded_file_options
    mod.before_save :save_embedded_files
  end
  
  attr_accessor :in_embedded_file
  #attr_accessor :in_embedded_resize_size
  #attr_accessor :in_embedded_thumbnail_size
  
  module ClassMethods
    def embed_file_of(*names)
      self.embedded_file_names   ||= []
      self.embedded_file_options ||= {}
      
      names.each do |name|
        opts = {}
        if name.is_a?(Hash)
          opts = name.values[0]
          name = name.keys[0]
        end
        self.embedded_file_names << name
        self.embedded_file_options[name] = opts
      end
      
      self.embedded_file_names.each do |name|
        self.belongs_to "embedded_file_relation_of_#{name}",
          :foreign_key => name,
          :class_name => 'Cms::EmbeddedFile',
          :dependent => :destroy
        #define_method("embedded_file_of_#{name}") { embedded_file_of(name) }
        #define_method("embedded_thumbnail_of_#{name}") { embedded_thumbnail_of(name) }
      end
    end
  end
  
  def embedded_file(name)
    send("embedded_file_relation_of_#{name}")
  end
  
  def embedded_thumbnail(name)
    file = embedded_file(name)
    return nil unless file
    return nil if file.image_is != 1 || !file.thumb_size
    
    file.image_width  = file.thumb_width
    file.image_height = file.thumb_height
    file.size         = file.thumb_size
    return file
  end
  
  def embedded_file_site_id
    return self.site_id if self.respond_to?(:site_id)    
    return self.content.site_id if self.respond_to?(:content)
    nil    
  end
  
  def embedded_file_state
    self.respond_to?(:state) ? self.state : 'closed'    
  end
  
  def set_embedded_file_option(name, options = {})
    @embeddef_file_options       ||= {}
    @embeddef_file_options[name] ||= {}
    @embeddef_file_options[name].merge!(options)
  end
  
  def embedded_file_option(name, type)
    if @embeddef_file_options && @embeddef_file_options[name]
      return @embeddef_file_options[name][type] if @embeddef_file_options[name][type]
    end
    if self.class.embedded_file_options[name].has_key?(type)
      return self.class.embedded_file_options[name][type]
    end
    return nil
  end
  
  def save_embedded_files
    names = self.class.embedded_file_names
    return true unless names
    
    in_embedded_file = self.in_embedded_file || {}
    
    names.each do |name|
      item = embedded_file(name)
      del  = in_embedded_file["_delete_#{name}"]
      file = in_embedded_file[name]
      
      if !item.nil?
        ## delete
        if !del.blank? == true && file.blank?
          item.destroy
          self.send("#{name}=", nil)
          next
        end
        
        ## inherit state
        if file.nil? && state != state_was
          item.state = embedded_file_state
          item.skip_upload(true)
          item.save
          next
        end
      end
      
      ## no upload
      next if file.nil?
      
      ## upload
      item     ||= Cms::EmbeddedFile.new
      item.file    = file
      item.name    = file.original_filename
      item.title   = item.name
      item.site_id = embedded_file_site_id
      item.state   = embedded_file_state
      
      item.use_resize embedded_file_option name, :resize
      item.use_thumbnail embedded_file_option name, :thumbnail
      
      if item.save
        self.send("#{name}=", item.id)
      end
    end
    return true
  end
end