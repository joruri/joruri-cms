# encoding: utf-8
class Cms::TalkTask < ActiveRecord::Base
  include Sys::Model::Base
  
  validates_presence_of :path
  
  before_destroy :remove_file
  
  def full_path
    p = ::File.join(Rails.root, path)
    p = p.gsub('/./', '/')
    p
  end
  
  def mp3_path
    "#{full_path}.mp3"
  end
  
protected
  
  def remove_file
    ::Storage.rm_rf(mp3_path) if ::Storage.exists?(mp3_path)
  end
end
