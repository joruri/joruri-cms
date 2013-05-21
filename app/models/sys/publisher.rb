# encoding: utf-8
class Sys::Publisher < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :unid
  
  before_validation :modify_path
  before_save :check_path
  before_destroy :remove_files
  
  def full_path
    p = ::File.join(Rails.root, path)
    p = p.gsub('/./', '/')
    p
  end
  
  def remove_files(options = {})
    up_path = options[:path] || path
    up_path = ::File.expand_path(path, Rails.root) if up_path.to_s =~ /^\//
    up_path = ::File.join(Rails.root, up_path).gsub('/./', '/') if up_path =~ /^\.\//
    
    ::Storage.rm_rf(up_path) if ::Storage.exists?(up_path)
    ::Storage.rm_rf("#{up_path}.mp3") if ::Storage.exists?("#{up_path}.mp3")
    ::Storage.rmdir(::File.dirname(path)) rescue nil
    return true
  end

protected
  
  def modify_path
    self.path = path.gsub(/^#{Rails.root.to_s}/, '.')
  end
  
  def check_path
    remove_files(:path => path_was) if !path_was.blank? && path_changed?
    return true
  end
end
