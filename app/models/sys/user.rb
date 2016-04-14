# encoding: utf-8
require 'digest/sha1'
class Sys::User < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::RoleName
  include Sys::Model::Auth::Manager

  include StateText

  has_many :group_rels, foreign_key: :user_id,
                        class_name: 'Sys::UsersGroup', primary_key: :id
  has_and_belongs_to_many :groups,
                          class_name: 'Sys::Group', join_table: 'sys_users_groups'
  has_and_belongs_to_many :role_names, association_foreign_key: :role_id,
                                       class_name: 'Sys::RoleName', join_table: 'sys_users_roles'

  attr_accessor :current_password, :new_password, :confirm_password

  validates :account, uniqueness: true
  validates :in_group_id, presence: true, if: %(in_group_id == '')
  validates :state, :account, :name, :ldap, presence: true

  after_save :save_users_roles
  after_save :save_group, if: %(@_in_group_id_changed)

  before_destroy :validate_destroy_admin,
                 if: %(auth_no == 5)

  scope :search, ->(params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_id'
        rel.where!(id: v)
      when 's_state'
        rel.where!(state: v)
      when 's_account'
        rel.where!(arel_table[:account].matches("%#{escape_like(v)}%"))
      when 's_name'
        rel.where!(arel_table[:name].matches("%#{escape_like(v)}%"))
      when 's_email'
        rel.where!(arel_table[:email].matches("%#{escape_like(v)}%"))
      when 's_group_id'
        rel.joins!(:groups).where!(sys_groups: { id: v == 'no_group' ? nil : v })
      end
    end

    rel
  }

  def validate_destroy_admin
    item = self.class.where(auth_no: 5)
                     .where.not(id: id)
                     .first
    return true if item
    false
  end

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
    Core.user.has_auth?(:manager)
  end

  def authes
    # [['なし',0], ['投稿者',1], ['作成者',2], ['編集者',3], ['設計者',4], ['管理者',5]]
    [['作成者', 2], ['設計者', 4], ['管理者', 5]]
  end

  def auth_name
    authes.each { |a| return a[0] if a[1] == auth_no }
    nil
  end

  def ldap_states
    [['同期', 1], ['非同期', 0]]
  end

  def ldap_label
    ldap_states.each { |a| return a[0] if a[1] == ldap }
    nil
  end

  def name_with_id
    "#{name}（#{id}）"
  end

  def name_with_account
    "#{name}（#{account}）"
  end

  def label(name)
    case name; when nil then end
  end

  def group(load = nil)
    return @group if @group && load
    @group = groups(load).empty? ? nil : groups[0]
  end

  def group_id(load = nil)
    (g = group(load)) ? g.id : nil
  end

  def in_group_id
    @in_group_id = (group ? group.id : nil) if @in_group_id.nil?
    @in_group_id
  end

  def in_group_id=(value)
    @_in_group_id_changed = true
    @in_group_id = value.to_s
  end

  def has_auth?(name)
    auth = {
      none: 0, # なし  操作不可
      reader: 1, # 読者  閲覧のみ
      creator: 2, # 作成者 記事作成者
      editor: 3, # 編集者 データ作成者
      designer: 4, # 設計者 デザイン作成者
      manager: 5 # 管理者 設定作成者
    }
    raise "Unknown authority name: #{name}" unless auth.key?(name)
    auth[name] <= auth_no
  end

  def has_priv?(action, options = {})
    return true unless options[:auth_off] || !has_auth?(:manager)
    return nil unless options[:item]

    item = options[:item]
    item = item.unid if item.is_a?(ActiveRecord::Base)

    priv = Sys::ObjectPrivilege.where(action: action.to_s, item_unid: item)
    return false if priv.empty?

    rids = priv.collect(&:role_id)

    rel = Sys::UsersRole.find_by(user_id: id, role_id: rids)
    return true if rel

    group.has_priv?(action, options) ? true : false
  end

  def delete_group_relations
    Sys::UsersGroup.delete_all(user_id: id)
    true
  end

  def self.find_managers
    where(state: 'enabled', auth_no: 5).order(:account)
  end

  ## -----------------------------------
  ## Authenticates

  ## Authenticates a user by their account name and unencrypted password.  Returns the user or nil.
  def self.authenticate(in_account, in_password, encrypted = false)
    crypt_pass  = Joruri.config[:sys_crypt_pass]
    in_password = Util::String::Crypt.decrypt(in_password, crypt_pass) if encrypted

    user = nil
    where(state: 'enabled', account: in_account).each do |u|
      ## valid user
      if u.ldap == 1
        ## LDAP Auth
        next unless ou1 = u.groups[0]
        next unless ou2 = ou1.parent
        dn = "uid=#{u.account},ou=#{ou1.ou_name},ou=#{ou2.ou_name},#{Core.ldap.base}"
        next unless Core.ldap.bind(dn, in_password)
        u.password = in_password
      else
        ## DB Auth
        next if in_password != u.password || u.password.to_s == ''
      end

      ## valid user group
      valid = true
      u.groups.each do |g|
        valid = false if g.state != 'enabled'
        valid = false if g.parent && g.parent.state != 'enabled'
      end
      valid = false if u.groups.empty?

      user = u if valid == true
      break
    end

    user
  end

  def encrypt_password
    return if password.blank?
    crypt_pass = Joruri.config[:sys_crypt_pass]
    Util::String::Crypt.encrypt(password, crypt_pass)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(validate: false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    # save(:validate => false)
    update_attributes remember_token_expires_at: nil, remember_token: nil
  end

  protected

  def password_required?
    password.blank?
  end

  def save_group
    exists = (group_rels.size > 0)

    group_rels.each_with_index do |rel, idx|
      if idx == 0 && !in_group_id.blank?
        if rel.group_id != in_group_id
          rel.group_id = in_group_id
          rel.save
        end
      else
        rel.destroy
      end
    end

    if !exists && !in_group_id.blank?
      rel = Sys::UsersGroup.create(user_id: id,
                                   group_id: in_group_id)
    end

    true
  end
end
