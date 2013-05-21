# encoding: utf-8
module Storage
  require "mime/types"
  require "nkf"
  
  @@env_key  = :file
  @@env_name = "File"
  
  def self.set_env(key, name)
    @@env_key  = key
    @@env_name = name
  end
  
  def self.env
    @@env_key
  end
  
  def self.env_name
    @@env_name
  end
  
  def self.import(path)
    return false if env == :file
    
    mkdir_p(::File.dirname(path))
    
    require 'find'
    Find.find(path) do |p|
      if ::File.directory?(p)
        mkdir_p(p)
      else
        binwrite p, ::File.binread(p)
      end
    end
  end
  
  def self.find(path)
    require 'find'
    Find.find(path)
  end
  
  def self.entries(path)
    paths = []
    ::Dir::entries(path).each {|p| paths << p if p !~ /^\.+$/ }
    paths
  end
  
  def self.exists?(path)
    ::File.exists?(path)
  end
  
  def self.directory?(path)
    ::FileTest.directory?(path)
  end
  
  def self.file?(path)
    ::FileTest.file?(path)
  end
  
  def self.mtime(path)
    ::File.stat(path).mtime
  end
  
  def self.size(path)
    ::File.stat(path).size
  end
  
  def self.kb_size(path)
    val = size(path)
    val ? (val/1000.0).ceil : nil
  end
  
  def self.mime_type(path)
    mime   = MIME::Types.type_for(path).first.content_type rescue nil
    mime ||= "text/html" if path =~ /\.html\.r$/
    mime
  end
  
  def self.mkdir(path)
    ::FileUtils.mkdir(path)
  end
  
  def self.mkdir_p(path)
    ::FileUtils.mkdir_p(path)
  end
  
  def self.mv(src, dst)
    ::FileUtils.mv(src, dst)
  end
  
  def self.cp(src, dst)
    ::FileUtils.cp(src, dst)
  end
  
  def self.rmdir(path)
    ::FileUtils.rmdir(path)
  end
  
  def self.rm_rf(path)
    ::FileUtils.rm_rf(path)
    #::FileUtils.remove_entry_secure(path, true) 
  end
  
  def self.touch(path)
    ::FileUtils.touch(path)
  end
  
  def self.read(path)
    ::File.read(path)
  end
  
  def self.binread(path)
    ::File.binread(path)
  end
  
  def self.write(path, data)
    data = data.force_encoding(Encoding::UTF_8) if data.respond_to?(:force_encoding)
    ::File.write(path, data)
  end
  
  def self.binwrite(path, data)
    ::File.binwrite(path, data)
  end
  
  def self.chmod(mode, path)
    ::File.chmod(mode, path)
  end
  
end