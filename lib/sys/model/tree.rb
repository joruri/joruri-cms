# encoding: utf-8
module Sys::Model::Tree
  def parents_tree(_options = {})
    climb_parents_tree(id, class: self.class)
  end

  def ancestors(items = [])
    parent.ancestors(items) if parent
    items << self
  end
  
  def descendants(items = [], &block)
    items << self
    rel = children
    rel = yield(rel) || rel if block_given?
    rel.each {|c| c.descendants(items, &block) }
    items
  end

  private

  def climb_parents_tree(id, options = {})
    climbed = [id]
    tree    = []
    while current = options[:class].find_by(id: id)
      tree.unshift(current)
      id = current.parent_id
      break if climbed.index(id)
      climbed << id
    end
    tree
  end
end
