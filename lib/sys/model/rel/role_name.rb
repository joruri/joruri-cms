# encoding: utf-8
module Sys::Model::Rel::RoleName

  def in_role_name_ids
    if @in_role_name_ids.nil?
      value = role_names ? role_names.collect{|c| c.id}.join(' ') : ''
      @in_role_name_ids = value.to_s
    end
    @in_role_name_ids
  end
  
  def in_role_name_ids=(value)
    @_in_role_name_ids_changed = true
    @in_role_name_ids = value.to_s
  end
  
private
  def save_groups_roles
    save_related_roles(:group)
  end
  
  def save_users_roles
    save_related_roles(:user)
  end
  
  def save_related_roles(mod)
    return true unless @_in_role_name_ids_changed
    return false if @sent_save_roles
    @sent_save_roles = true
    
    field = (mod == :user ? :user_id : :group_id)
     
    in_ids = []
    in_role_name_ids.split(' ').uniq.each{|id| in_ids << id.to_i if !id.blank?}
    
    Sys::UsersRole.find(:all, :conditions => {field => id}).each do |rel|
      if in_ids.index(rel.role_id)
        in_ids.delete(rel.role_id)
      else
        rel.destroy
      end
    end
    
    in_ids.each do |role_id|
      Sys::UsersRole.new({
        field    => self.id,
        :role_id => role_id,
      }).save
    end
    
    role_names(true)
    
    return true
  end
end