# encoding: utf-8
module Sys::Model::Rel::UnidRelation
  def self.included(mod)
    mod.has_many :rel_unids, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'Sys::UnidRelation'
    
    mod.after_destroy :remove_unid_relations
  end
  
  def remove_unid_relations
    replace_page?
    Sys::UnidRelation.destroy_all(:unid => unid)
    Sys::UnidRelation.destroy_all(:rel_unid => unid)
    return true
  end
  
  def unid_related?(options = {})
    cond = nil
    if options[:from]
      cond = {:unid => unid, :rel_type => options[:from].to_s}
    elsif options[:to]
      cond = {:rel_unid => unid, :rel_type => options[:to].to_s}
    else
      cond = ["unid = ? OR rel_unid = ?", unid, unid]
    end
    Sys::UnidRelation.find(:first, :conditions => cond) ? true : nil
  end
  
  def replace_page?
    return @unid_relation_replace_page if @unid_relation_replace_page
    cond = {:unid => unid, :rel_type => "replace"}
    @unid_relation_replace_page = Sys::UnidRelation.find(:first, :conditions => cond) ? true : nil
  end
  
  def replaced_page?
    cond = {:rel_unid => unid, :rel_type => "replace"}
    Sys::UnidRelation.find(:first, :conditions => cond) ? true : nil
  end
  
  def replace_page
    return nil unless replaced_page?
    cond = {:rel_unid => unid, :rel_type => "replace"}
    rel = Sys::UnidRelation.find(:first, :conditions => cond)
    self.class.find_by_unid(rel.unid)
  end
  
  def replaced_page
    return nil unless replace_page?
    cond = {:unid => unid, :rel_type => "replace"}
    rel = Sys::UnidRelation.find(:first, :conditions => cond)
    self.class.find_by_unid(rel.rel_unid)
  end
end
