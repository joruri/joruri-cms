# encoding: utf-8
module Sys::Model::Rel::EditableGroup
  
  def self.included(mod)
    mod.belongs_to :editable_group, :foreign_key => 'unid', :class_name => 'Sys::EditableGroup',
      :dependent => :destroy
    
    mod.after_save :save_editable_groups
  end
  
  def in_editable_groups
    unless val = @in_editable_groups
      val = []
      val = editable_group.group_ids.to_s.split(' ').uniq if editable_group
      @in_editable_groups = val
    end
    @in_editable_groups
  end
  
  def in_editable_groups=(ids)
    _ids = []
    if ids.class == Array
      _ids = ids
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess
      ids.each {|key, val| _ids << val unless val.blank? }
    else
      _ids = ids.to_s.split(' ').uniq
    end
    @editable_group_ids = _ids
  end
  
  def save_editable_groups
    return false unless unid
    return true unless @editable_group_ids
    
    value = @editable_group_ids.join(' ').strip
    @editable_group_ids = nil
    
    if editable_group
      editable_group.group_ids = value
      editable_group.save
    else
      group = Sys::EditableGroup.new
      group.id         = unid
      group.created_at = Core.now
      group.updated_at = Core.now
      group.group_ids  = value
      return false unless group.save_with_direct_sql
      editable_group(true)
    end
    return true
  end
end
