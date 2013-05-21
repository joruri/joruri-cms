# encoding: utf-8
class Sys::EditableGroup < ActiveRecord::Base
  include Sys::Model::Base
  
  def groups
    groups = []
    ids = group_ids.to_s.split(' ').uniq
    return groups if ids.size == 0
    ids.each do |id|
      group = Sys::Group.find_by_id(id)
      groups << group if group
    end
    groups
  end
end
