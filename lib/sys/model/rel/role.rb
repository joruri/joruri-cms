# encoding: utf-8
module Sys::Model::Rel::Role
  extend ActiveSupport::Concern

  included do
    scope :has_priv, ->(name, options = {}) {
      user = options[:user]
      return self if user.has_auth?(:manager)

      gids = user.group.parents_tree.collect(&:id)

      rids = Sys::UsersRole
             .where(user_id: user.id)
             .where(group_id: gids)
             .select(:role_id)
             .collect(&:role_id)

      rids = !rids.empty? ? rids * ',' : '-1'

      sql = "SELECT item_unid FROM sys_object_privileges" +
        " WHERE action = '#{name}' AND role_id IN (#{rids}) "

      sql = "INNER JOIN (#{sql}) AS sys_object_privileges" +
        " ON sys_object_privileges.item_unid = #{self.class.table_name}.unid"

      rel.joins(sql)
    }
  end
end
