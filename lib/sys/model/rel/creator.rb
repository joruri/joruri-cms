# encoding: utf-8
module Sys::Model::Rel::Creator
  
  def self.included(mod)
    mod.belongs_to :creator, :foreign_key => 'unid', :class_name => 'Sys::Creator',
      :dependent => :destroy
    
    mod.after_save :save_creator
  end
  
  def in_creator
    unless val = @in_creator
      val = {}
      creator.attributes.each do |k,v|
        val[k.to_s] = v
      end if creator
      @in_creator = val
    end
    @in_creator
  end
  
  def in_creator=(values)
    @creator_ids = values
    @creator_ids.each {|k,v| @creator_ids[k] = nil if v.blank? }
    @in_creator = @creator_ids
  end
  
  def join_creator
    return true if @joined_creator
    @joined_creator = true
    join :creator
  end
  
  def save_creator
    return false unless unid
    
    unless @creator_ids
      if creator && !creator.user_id.blank?
        return true
      end
    end
    
    @creator_ids ||= {}
    group_id = @creator_ids['group_id'] || Core.user_group.id
    user_id  = @creator_ids['user_id']  || Core.user.id
    
    if creator
      creator.group_id = group_id
      creator.user_id  = user_id
      return creator.save
    end
    
    _creator = Sys::Creator.new
    _creator.id         = unid
    _creator.created_at = Core.now
    _creator.updated_at = Core.now
    _creator.group_id   = group_id
    _creator.user_id    = user_id
    return false unless _creator.save_with_direct_sql
    creator(true)
    return true
  end
end
