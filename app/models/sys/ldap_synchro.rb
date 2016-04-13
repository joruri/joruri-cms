# encoding: utf-8
class Sys::LdapSynchro < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Tree
  include Sys::Model::Auth::Manager

  validates :version, :entry_type, :code, :name, presence: true

  def children
    return @_children if @_children
    cond = { version: version, parent_id: id, entry_type: 'group' }
    @_children = self.class.where(cond).order(:sort_no, :code)
  end

  def users
    return @_users if @_users
    cond = { version: version, parent_id: id, entry_type: 'user' }
    @_users = self.class.where(cond).order(:sort_no, :code)
  end

  def group_count
    cond = { version: version, entry_type: 'group' }
    self.class.where(cond).count
  end

  def user_count
    cond = { version: version, entry_type: 'user' }
    self.class.where(cond).count
  end
end
