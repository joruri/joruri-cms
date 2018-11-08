# encoding: utf-8
class Sys::Group < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page
  include Sys::Model::Base::Config
  include Cms::Model::Base::Page::Publisher
  include Cms::Model::Base::Page::TalkTask
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::RoleName
  include Sys::Model::Tree
  include Sys::Model::Auth::Manager

  include StateText

  belongs_to :parent, foreign_key: :parent_id, class_name: 'Sys::Group'
  belongs_to :layout, foreign_key: :layout_id, class_name: 'Cms::Layout'

  has_many   :children, -> { order(:code) }, foreign_key: :parent_id, class_name: 'Sys::Group', dependent: :destroy
  has_and_belongs_to_many :users, -> { order(Sys::User.arel_table[:id]) }, class_name: 'Sys::User', join_table: 'sys_users_groups'
  has_and_belongs_to_many :role_names, association_foreign_key: :role_id,
                                       class_name: 'Sys::RoleName', join_table: 'sys_users_roles', foreign_key: :group_id

  validates :state, :level_no, :name, :name_en, :ldap, presence: true
  validates :code, presence: true, uniqueness: true
  validates :parent_id, presence: true, if: %(level_no_was.blank? || level_no_was != 1)

  after_save :save_groups_roles

  before_destroy :before_destroy

  def readable
    self
  end

  def creatable?
    Core.user.has_auth?(:manager)
  end

  def readable?
    Core.user.has_auth?(:manager)
  end

  def editable?
    Core.user.has_auth?(:manager)
  end

  def deletable?
    return false if has_admin_user?
    return false if children.count { |c| !c.deletable? } > 0

    Core.user.has_auth?(:manager)
  end

  def has_admin_user?
    return true if users.count { |user| user.groups.size == 1 && user.auth_no == 5 && user.state == 'enabled' } > 0
    false
  end

  def ldap_states
    [['同期', 1], ['非同期', 0]]
  end

  def web_states
    [%w(公開 public), %w(非公開 closed)]
  end

  def ldap_label
    ldap_states.each { |a| return a[0] if a[1] == ldap }
    nil
  end

  def ou_name
    "#{code}#{name}"
  end

  def full_name
    n = name
    if Sys::Setting.value(:display_parent_group_name) == 'enabled'
      parent_names = parents_tree.select{|g| g.level_no > 1}
      n = parent_names.map{|g| g.name }.join('　')
    else
      n = "#{parent.name}　#{n}" if parent && parent.level_no > 1
    end
    n
  end

  def has_priv?(action, options = {})
    return nil unless options[:item]

    item = options[:item]
    item = item.unid if item.is_a?(ActiveRecord::Base)

    cond = { action: action.to_s, item_unid: item }
    priv = Sys::ObjectPrivilege.where(cond)
    return false if priv.empty?

    rids = priv.collect(&:role_id)
    gids = parents_tree.collect(&:id)

    rel = Sys::UsersRole.where(group_id: gids, role_id: rids).first
    rel ? true : false
  end

  private

  def before_destroy
    raise "can't be deleted." if has_admin_user?

    users.each do |user|
      next unless user.groups.size == 1
      u = Sys::User.find_by(id: user.id)
      u.state = 'disabled'
      u.save
    end
    true
  end
end
