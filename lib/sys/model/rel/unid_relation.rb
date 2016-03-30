# encoding: utf-8
module Sys::Model::Rel::UnidRelation
  def self.included(mod)
    mod.has_many :rel_unids, primary_key: 'unid', foreign_key: 'unid', class_name: 'Sys::UnidRelation'

    mod.after_destroy :remove_unid_relations
  end

  def remove_unid_relations
    replace_page?
    Sys::UnidRelation.destroy_all(unid: unid)
    Sys::UnidRelation.destroy_all(rel_unid: unid)
    true
  end

  def unid_related?(options = {})
    cond = nil
    cond = if options[:from]
             { unid: unid, rel_type: options[:from].to_s }
           elsif options[:to]
             { rel_unid: unid, rel_type: options[:to].to_s }
           else
             ['unid = ? OR rel_unid = ?', unid, unid]
           end
    Sys::UnidRelation.find_by(cond) ? true : nil
  end

  def replace_page?
    return @unid_relation_replace_page if @unid_relation_replace_page
    @unid_relation_replace_page = Sys::UnidRelation.find_by(unid: unid, rel_type: 'replace') ? true : nil
  end

  def replaced_page?
    cond = { rel_unid: unid, rel_type: 'replace' }
    Sys::UnidRelation.find_by(cond) ? true : nil
  end

  def replace_page
    return nil unless replaced_page?
    cond = { rel_unid: unid, rel_type: 'replace' }
    rel = Sys::UnidRelation.find_by(cond)
    self.class.find_by(unid: rel.unid)
  end

  def replaced_page
    return nil unless replace_page?
    cond = { unid: unid, rel_type: 'replace' }
    rel = Sys::UnidRelation.find_by(cond)
    self.class.find_by(unid: rel.rel_unid)
  end
end
