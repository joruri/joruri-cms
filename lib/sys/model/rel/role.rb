# encoding: utf-8
module Sys::Model::Rel::Role
  
  def has_priv(name, options = {})
    user = options[:user]
    return self if user.has_auth?(:manager)
    
    gids = user.group.parents_tree.collect{|g| g.id }
    
    sql = "SELECT role_id FROM #{Sys::UsersRole.table_name} WHERE user_id = #{user.id} OR group_id IN (#{gids.join(',')})"
    sql = "SELECT item_unid FROM sys_object_privileges WHERE action = '#{name}' AND role_id IN (#{sql}) "
    sql = "INNER JOIN (#{sql}) AS sys_object_privileges ON sys_object_privileges.item_unid = #{self.class.table_name}.unid"
    
    join sql
    
    return self
  end
end