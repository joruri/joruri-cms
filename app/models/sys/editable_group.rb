# encoding: utf-8
class Sys::EditableGroup < ActiveRecord::Base
  include Sys::Model::Base

  def groups
    groups = []
    ids = group_ids.to_s.split(' ').uniq
    return groups if ids.empty?
    ids.each do |id|
      group = Sys::Group.find_by(id: id)
      groups << group if group
    end
    groups
  end
end
