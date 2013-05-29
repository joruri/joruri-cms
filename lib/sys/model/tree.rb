# encoding: utf-8
module Sys::Model::Tree
  def parents_tree(options = {})
    climb_parents_tree(id, :class => self.class)
  end
  
private
  def climb_parents_tree(id, options = {})
    climbed = [id]
    tree    = []
    while current = options[:class].find_by_id(id)
      tree.unshift(current)
      id = current.parent_id
      break if climbed.index(id)
      climbed << id
    end
    return tree
  end
end
