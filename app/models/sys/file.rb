# encoding: utf-8
class Sys::File < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::File
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  
  attr_accessor :in_resize_size, :in_thumbnail_size
  #validates_presence_of :name
  
  ## garbage collect
  def self.garbage_collect
    conditions = Condition.new
    conditions.and :tmp_id, 'IS NOT', nil
    conditions.and :parent_unid, 'IS', nil
    conditions.and :created_at, '<', (Date.strptime(Core.now, "%Y-%m-%d") - 2)
    destroy_all(conditions.where)
  end
  
  ## Remove the temporary flag.
  def self.fix_tmp_files(tmp_id, parent_unid)
    updates = {:parent_unid => parent_unid, :tmp_id => nil }
    conditions = ["parent_unid IS NULL AND tmp_id = ?", tmp_id]
    update_all(updates, conditions)
  end
  
  def duplicated?
    file = self.class.new
    file.and :id, "!=", id if id
    file.and :name, name
    if tmp_id
      file.and :tmp_id, tmp_id
      file.and :parent_unid, 'IS', nil
    else
      file.and :tmp_id, 'IS', nil
      file.and :parent_unid, parent_unid
    end
    return file.find(:first)
  end
end
