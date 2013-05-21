# encoding: utf-8
class Sys::LdapSynchro < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Tree
  include Sys::Model::Auth::Manager
  
  validates_presence_of :version, :entry_type, :code, :name
  
  def children
    return @_children if @_children
    cond = {:version => version, :parent_id => id, :entry_type => 'group'}
    @_children = self.class.find(:all, :conditions => cond, :order => 'sort_no, code')
  end
  
  def users
    return @_users if @_users
    cond = {:version => version, :parent_id => id, :entry_type => 'user'}
    @_users = self.class.find(:all, :conditions => cond, :order => 'sort_no, code')
  end
  
  def group_count
    cond = {:version => version, :entry_type => 'group'}
    self.class.count(:conditions => cond)
  end
  
  def user_count
    cond = {:version => version, :entry_type => 'user'}
    self.class.count(:conditions => cond)
  end
end
