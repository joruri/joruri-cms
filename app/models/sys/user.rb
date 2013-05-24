# encoding: utf-8
require 'digest/sha1'
class Sys::User < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::RoleName
  include Sys::Model::Auth::Manager

  belongs_to :status,     :foreign_key => :state,
    :class_name => 'Sys::Base::Status'
  has_many   :group_rels, :foreign_key => :user_id,
    :class_name => 'Sys::UsersGroup'  , :primary_key => :id
  has_and_belongs_to_many :groups,
    :class_name => 'Sys::Group', :join_table => 'sys_users_groups'
  has_and_belongs_to_many :role_names, :association_foreign_key => :role_id,
    :class_name => 'Sys::RoleName', :join_table => 'sys_users_roles'
  
#  attr_accessible :remember_token_expires_at, :remember_token
  
  attr_accessor :current_password, :new_password, :confirm_password
#  attr_accessor :in_group_id, :current_password, :new_password, :confirm_password
  
  validates_uniqueness_of :account
  
  validates_presence_of :in_group_id, :if => %Q(in_group_id == '')
  validates_presence_of :state, :account, :name, :ldap
  
  after_save :save_users_roles
  after_save :save_group, :if => %Q(@_in_group_id_changed)

  before_destroy :validate_destroy_admin,
    :if => %Q(auth_no == 5)
  
  def validate_destroy_admin
    item = self.class.new
    item.and :auth_no, 5
    item.and :id, '!=', id
    if item.find(:first)
      return true
    end
    return false
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
    #[['なし',0], ['投稿者',1], ['作成者',2], ['編集者',3], ['設計者',4], ['管理者',5]]
    [['作成者',2], ['設計者',4], ['管理者',5]]
  end
  
  def auth_name
    authes.each {|a| return a[0] if a[1] == auth_no }
    return nil
  end
  
  def ldap_states
    [['同期',1],['非同期',0]]
  end
  
  def ldap_label
    ldap_states.each {|a| return a[0] if a[1] == ldap }
    return nil
  end
  
  def name_with_id
    "#{name}（#{id}）"
  end

  def name_with_account
    "#{name}（#{account}）"
  end
  
  def label(name)
    case name; when nil; end
  end
  
  def group(load = nil)
    return @group if @group && load
    @group = groups(load).size == 0 ? nil : groups[0]
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
      :none     => 0, # なし  操作不可
      :reader   => 1, # 読者  閲覧のみ
      :creator  => 2, #作成者 記事作成者
      :editor   => 3, #編集者 データ作成者
      :designer => 4, #設計者 デザイン作成者
      :manager  => 5, #管理者 設定作成者
    }
    raise "Unknown authority name: #{name}" unless auth.has_key?(name)
    return auth[name] <= auth_no
  end

  def has_priv?(action, options = {})
    unless options[:auth_off]
      return true if has_auth?(:manager)
    end
    return nil unless options[:item]

    item = options[:item]
    item = item.unid if item.kind_of?(ActiveRecord::Base)
    
    cond = {:action => action.to_s, :item_unid => item}
    priv = Sys::ObjectPrivilege.find(:all, :conditions => cond)
    return false if priv.size == 0
    
    rids = priv.collect{|p| p.role_id}
    
    rel = Sys::UsersRole.new
    rel.and :user_id, id
    rel.and :role_id, 'IN', rids
    return true if rel.find(:first)
    
    return group.has_priv?(action, options) ? true : false
  end

  def delete_group_relations
    Sys::UsersGroup.delete_all(:user_id => id)
    return true
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and :id, v
      when 's_state'
        self.and 'sys_users.state', v
      when 's_account'
        self.and 'sys_users.account', 'LIKE', "%#{v.gsub(/([%_])/, '\\\\\1')}%"
      when 's_name'
        self.and 'sys_users.name', 'LIKE', "%#{v.gsub(/([%_])/, '\\\\\1')}%"
      when 's_email'
        self.and 'sys_users.email', 'LIKE', "%#{v.gsub(/([%_])/, '\\\\\1')}%"
      when 's_group_id'
        if v == 'no_group'
          self.join 'LEFT OUTER JOIN sys_users_groups ON sys_users_groups.user_id = sys_users.id' +
            ' LEFT OUTER JOIN sys_groups ON sys_users_groups.group_id = sys_groups.id'
          self.and 'sys_groups.id',  'IS', nil
        else
          self.join :groups
          self.and 'sys_groups.id', v
        end
      end
    end if params.size != 0

    return self
  end

  def self.find_managers
    cond = {:state => 'enabled', :auth_no => 5}
    self.find(:all, :conditions => cond, :order => :account)
  end
  
  ## -----------------------------------
  ## Authenticates

  ## Authenticates a user by their account name and unencrypted password.  Returns the user or nil.
  def self.authenticate(in_account, in_password, encrypted = false)
    crypt_pass  = Joruri.config[:sys_crypt_pass]
    in_password = Util::String::Crypt.decrypt(in_password, crypt_pass) if encrypted
    
    user = nil
    self.new.enabled.find(:all, :conditions => {:account => in_account, :state => 'enabled'}).each do |u|
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
        valid = false if g.state != "enabled"
        valid = false if g.parent && g.parent.state != "enabled"
      end
      valid = false if u.groups.size == 0
      
      user = u if valid == true
      break
    end
    return user
  end

  def encrypt_password
    return if password.blank?
    crypt_pass  = Joruri.config[:sys_crypt_pass]
    Util::String::Crypt.encrypt(password, crypt_pass)
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(:validate => false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    #save(:validate => false)
    update_attributes :remember_token_expires_at => nil, :remember_token => nil
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
      rel = Sys::UsersGroup.create({
        :user_id  => id,
        :group_id => in_group_id
      })
    end
    
    return true
  end
end
