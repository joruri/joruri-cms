# encoding: utf-8
class EntityConversion::Unit < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Content
  
  belongs_to :web_status, :foreign_key => :web_state, :class_name => 'Sys::Base::Status'
  belongs_to :content, :foreign_key => :content_id, :class_name => 'Cms::Content'
  belongs_to :layout, :foreign_key => :layout_id, :class_name => 'Cms::Layout'
  
  belongs_to :old, :foreign_key => :old_id, :class_name => 'Sys::Group'
  belongs_to :old_parent, :foreign_key => :old_parent_id, :class_name => 'Sys::Group'
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Sys::Group'
  belongs_to :move, :foreign_key => :move_id, :class_name => 'Sys::Group'
  belongs_to :new_parent, :foreign_key => :new_parent_id, :class_name => 'EntityConversion::Unit'
  belongs_to :new_move, :foreign_key => :new_move_id, :class_name => 'EntityConversion::Unit'
  
  validates_presence_of :code, :name, :name_en, :web_state, :ldap,
    :if => %Q(state == "new")
  validates_presence_of :old_id, :code, :name, :name_en, :web_state, :ldap,
    :if => %Q(state == "edit")
  validates_presence_of :old_id,
    :if => %Q(state == "move")
  validates_presence_of :old_id,
    :if => %Q(state == "end")
  
  validate :validates_all
  validate :validates_new_parent_id,
    :if => %Q(state =~ /^(new)$/)
  validate :validates_new_move_id,
    :if => %Q(state =~ /^(move)$/)
  
  def ldap_states
    Sys::Group.new.ldap_states
  end
  
  def web_states
    Sys::Group.new.web_states
  end
  
  def ldap_label
    ldap_states.each {|a| return a[0] if a[1] == ldap }
    return nil
  end
  
  def full_name
    pname  = nil
    
    if parent
      pname  = parent.name
    elsif parent = old_parent
      pname  = parent.name
    elsif parent = new_parent
      pname  = parent.name
    end
    
    return (pname && level_no > 2) ? "#{pname}　#{name}" : name
  end
  
  def level_no
    if parent
      parent.level_no + 1
    elsif parent = old_parent
      parent.level_no + 1
    elsif parent = new_parent
      if parent.parent
        parent.parent.level_no + 2
      elsif parent.new_parent
        parent.new_parent.parent.level_no + 3
      end
    else
      raise "undefined level_no "
    end
  end
  
  def replace_texts
    return [] if state !~ /^(edit|move)$/
    
    dst_unit = self
    dst_unit = move if state == "move" && move
    dst_unit = new_move if state == "move" && new_move
    return [] if !old || !dst_unit
    
    list  = []
    
    [:full_name, :name, :name_en, :email, :tel, :outline_uri].each do |key|
      src = old.send(key)
      dst = dst_unit.send(key)
      next if src.blank? || dst.blank? || src == dst
      
      if key == :full_name
        list << [src.gsub("　", ""), dst.gsub("　", "")]
        list << [src.gsub("　", " "), dst.gsub("　", " ")]
      elsif key == :name
        next if Sys::Group.find(:all, :conditions => {:name => src}).size > 1
      elsif key == :name_en
        next if Sys::Group.find(:all, :conditions => {:name_en => src}).size > 1
      end
      list << [src, dst]
    end
    list.uniq
  end
  
  def validates_all
    if !old_id.blank?
      old = Sys::Group.find_by_id(old_id)
      self.old_parent_id = old.parent_id if old
      errors.add :old_id, :invalid if !old
    end
  end
  
  def validates_new_parent_id
    num = (parent_id.blank? ? 0 : 1) + (new_parent_id.blank? ? 0 : 1)
    errors.add :parent_id, :choice_one if num != 1
  end
  
  def validates_new_move_id
    num = (move_id.blank? ? 0 : 1) + (new_move_id.blank? ? 0 : 1)
    errors.add :move_id, :choice_one if num != 1
    
    errors.add :move_id, :invalid if !move_id.blank? && old_id == move_id
  end
  
end