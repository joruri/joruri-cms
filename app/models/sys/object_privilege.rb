# encoding: utf-8
class Sys::ObjectPrivilege < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Auth::Manager

  belongs_to :unid_original, foreign_key: 'item_unid', class_name: 'Sys::Unid'
  belongs_to :concept, foreign_key: 'item_unid', primary_key: 'unid',
                       class_name: 'Cms::Concept'

  validates :role_id, :item_unid, presence: true
  validates :action, presence: true, if: %(in_actions.blank?)

  def in_actions
    @in_actions = actions if @in_actions.nil?
    @in_actions
  end

  def in_actions=(values)
    @_in_actions_changed = true
    _values = []
    if values.class == Hash || values.class == HashWithIndifferentAccess \
      || values.class == ActionController::Parameters
      values.each { |key, val| _values << key unless val.blank? }
      @in_actions = _values
    else
      @in_actions = values
    end
  end

  def action_labels(format = nil)
    list = [%w(閲覧 read), %w(作成 create), %w(編集 update), %w(削除 delete)]
    if format == :hash
      h = {}
      list.each { |c| h[c[1]] = c[0] }
      return h
    end
    list
  end

  def privileges
    self.class.where(role_id: role_id, item_unid: item_unid).order(:action)
  end

  def actions
    privileges.collect(&:action)
  end

  def action_names
    names = []
    _actions = actions
    action_labels.each do |label, key|
      if actions.index(key)
        names << label
        _actions.delete(key)
      end
    end
    names += _actions
    names
  end

  def save
    return super unless @_in_actions_changed
    return false unless valid?
    save_actions
  end

  def destroy_actions
    privileges.each(&:destroy)
    true
  end

  protected

  def save_actions
    values = in_actions.clone

    cond = { role_id: role_id, item_unid: (item_unid_was || item_unid) }
    old_privileges = self.class.where(cond).order(:action)

    old_privileges.each do |priv|
      if values.index(priv.action)
        if item_unid != priv.item_unid
          priv.item_unid = item_unid
          priv.save
        end
      else
        priv.destroy
      end
      values.delete(priv.action)
    end

    values.each do |value|
      Sys::ObjectPrivilege.new(role_id: role_id,
                               item_unid: item_unid,
                               action: value).save
    end

    true
  end
end
