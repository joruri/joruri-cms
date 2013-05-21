# encoding: utf-8
class Sys::Recognition < ActiveRecord::Base
  include Sys::Model::Base
  
  belongs_to :user,  :foreign_key => :user_id,  :class_name => 'Sys::User'
  
  attr_accessor :type
  
  def type=(type)
    if type.to_s == 'with_admin'
      self.extend(Sys::Model::Recognition::WithAdmin)
    end
  end
  
  def info(user_id = nil)
    info = nil
    info = Sys::Model::Recognition::Info::Base.find(user_id, self) if user_id
    info ||= Sys::Model::Recognition::Info::Base.new(self)
  end
  
  def reset_info
    self.info_xml = nil
    save
    
    recognizers.each do |user|
      i = info(user.id)
      i.id = user.id
      i.recognized_at = nil
      i.save
    end
  end
  
  def recognizers
    return @_recognizers if @_recognizers
    users = []
    recognizer_ids.to_s.split(' ').uniq.each do |id|
      if u = Sys::User.find_by_id(id)
        users << u
      end
    end
    @_recognizers = users
  end
  
  def recognizable?(user)
    info = info(user.id)
    return false if info.id.blank?
    return false if info.id.to_s != user.id.to_s
    return false if !info.recognized_at.blank?
    return true
  end
  
  def recognize(user)
    return false if !user || !user.id
    return false if recognizer_ids !~ /(^| )#{user.id}( |$)/
    
    info = info(user.id)
    info.id            = user.id
    info.recognized_at = Core.now
    info.save
  end
  
  def recognized_all?
    rs = true
    info(:all).each do |i|
      return false if i.recognized_at.blank?
    end
    return true
  end
  
  def to_a
    list = []
    recognizers.each do |user|
      date = info(user.id).recognized_at
      list << { :user => user, :recognized_at => (date.blank? ? nil : date) }
    end
    list
  end
end
