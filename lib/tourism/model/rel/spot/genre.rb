# encoding: utf-8
module Tourism::Model::Rel::Spot::Genre
  
  def in_genre_ids
    unless val = @in_genre_ids
      @in_genre_ids = genre_ids.to_s.split(' ').uniq
    end
    @in_genre_ids
  end
  
  def in_genre_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each {|val| _ids << val}
      self.genre_ids = _ids.join(' ')
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess
      ids.each {|key, val| _ids << val}
      self.genre_ids = _ids.join(' ')
    else
      self.genre_ids = ids
    end
  end
  
  def genre_items(options = {})
    ids = genre_ids.to_s.split(' ').uniq
    return [] if ids.size == 0
    item = Tourism::Genre.new
    item.and :id, 'IN', ids
    item.and :state, options[:state] if options[:state]
    item.find(:all)
  end
  
  def genre_is(cate)
    return self if cate.blank?
    cate = [cate] unless cate.class == Array
    ids  = []
    
    searcher = lambda do |_cate|
      _cate.each do |_c|
        next if _c.level_no > 4
        next if ids.index(_c.id)
        ids << _c.id
        searcher.call(_c.public_children)
      end
    end
    
    searcher.call(cate)
    ids = ids.uniq
    
    if ids.size > 0
      self.and :genre_ids, 'REGEXP', "(^| )(#{ids.join('|')})( |$)"
    end
    return self
  end
  
  def genres_and_unit
    "（TODO: genres_and_unit）"
  end
end