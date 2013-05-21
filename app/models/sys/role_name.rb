# encoding: utf-8
class Sys::RoleName < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager
  
  has_many :privileges, :foreign_key => :role_id, :class_name => 'Sys::ObjectPrivilege',
    :dependent => :destroy
    
  validates_presence_of :name, :title
  
  def groups
    item = Sys::UsersRole.new
    item.and :role_id, id
    item.and :group_id, "IS NOT", nil
    ids = item.find(:all).collect{|u| u.group_id }
    return [] if ids.size == 0
    
    item = Sys::Group.new
    item.and :id, 'IN', ids
    item.find(:all, :order => 'sort_no, code, id')
  end
  
  def users
    item = Sys::UsersRole.new
    item.and :role_id, id
    item.and :user_id, "IS NOT", nil
    ids = item.find(:all).collect{|u| u.user_id }
    return [] if ids.size == 0
    
    item = Sys::User.new
    item.and :id, 'IN', ids
    item.find(:all, :order => :account)
  end
end
