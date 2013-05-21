# encoding: utf-8

require "storage"
Storage.set_env(:db, "DB")

module Storage
  
  def self.find(path)
    ::Storage::Db.find(path)
  end
  
  def self.entries(path)
    ::Storage::Db.entries(path)
  end
  
  def self.exists?(path)
    ::Storage::Db.exists?(path)
  end
  
  def self.directory?(path)
    ::Storage::Db.directory?(path)
  end
  
  def self.file?(path)
    ::Storage::Db.file?(path)
  end
  
  def self.mtime(path)
    ::Storage::Db.mtime(path)
  end
  
  def self.size(path)
    ::Storage::Db.size(path)
  end
  
  #def self.mime_type(path)
  #  ::Storage::Db.mime_type(path)
  #end
  
  def self.mkdir(path)
    ::Storage::Db.mkdir(path)
  end
  
  def self.mkdir_p(path)
    ::Storage::Db.mkdir_p(path)
  end
  
  def self.mv(src, dst)
    ::Storage::Db.mv(src, dst)
  end
  
  def self.cp(src, dst)
    ::Storage::Db.cp(src, dst)
  end
  
  def self.rmdir(path)
    ::Storage::Db.rmdir(path)
  end
  
  def self.rm_rf(path)
    ::Storage::Db.rm_rf(path)
  end
  
  def self.touch(path)
    ::Storage::Db.touch(path)
  end
  
  def self.read(path)
    ::Storage::Db.read(path)
  end
  
  def self.binread(path)
    ::Storage::Db.binread(path)
  end
  
  def self.write(path, data)
    ::Storage::Db.write(path, data)
  end
  
  def self.binwrite(path, data)
    ::Storage::Db.binwrite(path, data)
  end
  
  def self.chmod(mode, path)
    ::Storage::Db.chmod(mode, path)
  end
  
end
