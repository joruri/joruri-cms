# encoding: utf-8
module Article::Model::Rel::Doc::Category
  
  def in_category_ids
    unless val = @in_category_ids
      @in_category_ids = category_ids.to_s.split(' ').uniq
    end
    @in_category_ids
  end
  
  def in_category_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each {|val| _ids << val}
      self.category_ids = _ids.join(' ')
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess
      ids.each {|key, val| _ids << val}
      self.category_ids = _ids.join(' ')
    else
      self.category_ids = ids
    end
  end
  
  def category_items(options = {})
    ids = category_ids.to_s.split(' ').uniq
    return [] if ids.size == 0
    item = Article::Category.new
    item.and :id, 'IN', ids
    item.and :state, options[:state] if options[:state]
    item.find(:all)
  end
  
  def category_is(cate)
    return self if cate.blank?
    cate = [cate] unless cate.class == Array
    ids  = []
    
    searcher = lambda do |_cate|
      _cate.each do |_c|
        next if _c.blank?
        next if _c.level_no > 4
        next if ids.index(_c.id)
        ids << _c.id
        searcher.call(_c.public_children)
      end
    end
    
    searcher.call(cate)
    ids = ids.uniq
    
    if ids.size > 0
      self.and :category_ids, 'REGEXP', "(^| )(#{ids.join('|')})( |$)"
    end
    return self
  end
end