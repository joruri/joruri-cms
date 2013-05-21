# encoding: utf-8
require 'digest/md5'
class Storage::File < ActiveRecord::Base
  include Sys::Model::Base
  
  validates :path, :uniqueness => true
  
  def self.create_dir(path)
    item = self.new(:directory => true)
    item.set_path(path)
    item.set_data(nil)
    item.save
  end
  
  def self.create_file(path, data = "")
    item = self.new(:directory => false)
    item.set_path(path)
    item.set_data(data)
    item.save
  end
  
  def set_path(path)
    self.path      = path
    self.dirname   = ::File.dirname(path)
    self.basename  = ::File.basename(path)
    self.path_hash = Digest::MD5.new.update(self.path).to_s
    self.dir_hash  = Digest::MD5.new.update(self.dirname).to_s
    self
  end
  
  def set_data(data)
    self.data = data
    self.size = (data ? data.size : 0)
    self
  end
  
  def update_path(path)
    set_path(path)
    save
  end
  
  def update_data(data)
    set_data(data)
    save
  end
  
end
