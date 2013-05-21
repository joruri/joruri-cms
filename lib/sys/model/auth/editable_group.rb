# encoding: utf-8
module Sys::Model::Auth::EditableGroup
  def editable
    return self if Core.user.has_auth?(:manager)
    
    self.join :editable_group
    self.and Condition.new do |c|
      col = "sys_editable_groups.group_ids"
      val = Core.user_group.id
      c.or col, 'REGEXP', "(^| )#{val}( |$)"
      
      join_creator
      c.or "sys_creators.group_id", Core.user_group.id 
    end
    return self
  end
  
  def creatable?
    return false unless Core.user.has_auth?(:creator)
    #return Core.user.has_priv?(:create, :item => content.concept)
    return true
  end
  
  def editable?
    return true if Core.user.has_auth?(:manager)
    return false unless creator
    return true if creator.group_id == Core.user_group.id
    return false unless editable_group
    return editable_group.group_ids =~ /(^| )#{Core.user_group.id}( |$)/
  end
  
  def deletable?
    editable?
  end
end
