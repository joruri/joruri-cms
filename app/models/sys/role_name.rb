# encoding: utf-8
class Sys::RoleName < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  has_many :privileges, foreign_key: :role_id, class_name: 'Sys::ObjectPrivilege',
                        dependent: :destroy

  validates_presence_of :name, :title

  def groups
    ids = Sys::UsersRole
          .where(role_id: id)
          .where.not(group_id: nil)
          .collect(&:group_id)
    return [] if ids.size == 0

    Sys::Group.where(id: ids).order(:sort_no, :code, :id)
  end

  def users
    ids = Sys::UsersRole
          .where(role_id: id)
          .where.not(user_id, nil)
          .collect(&:user_id)
    return [] if ids.size == 0

    Sys::User.where(id: ids).order(:account)
  end
end
