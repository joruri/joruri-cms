# encoding: utf-8
module Sys::Model::Recognition::WithAdmin
  def admin_info(user_id = nil)
    info = nil
    info = Sys::Model::Recognition::Info::Admin.find(user_id, self) if user_id
    info ||= Sys::Model::Recognition::Info::Admin.new(self)
  end
  
  def recognizable?(user)
    return true if super
    return false unless user.has_auth?(:manager)
    return false unless recognized_all?(false)
    return recognized_admin? ? false : true
  end
  
  def recognize(user)
    rs = super
    return rs unless recognized_all?(false)
    
    if user.has_auth?(:manager)
      info = admin_info(user.id)
      info.id            = user.id
      info.recognized_at = Core.now
      return info.save
    else
      info = admin_info(user.id)
      info.id            = nil
      info.recognized_at = nil
      return info.save
    end
  end
  
  def recognized_admin?
    admin_info(:all).each do |u|
      return true if !u.id.blank? && !u.recognized_at.blank?
    end
    false
  end
  
  def recognized_all?(with_admin = true)
    return super() unless with_admin
    return false unless super()
    return recognized_admin?
  end
  
  def to_a
    list = super
    admin_info(:all).each do |u|
      next unless user = Sys::User.find_by_id(u.id)
      next if user.id.blank?
      date = u.recognized_at
      list << { :user => user, :recognized_at => (date.blank? ? nil : date) }
    end
    list
  end
end