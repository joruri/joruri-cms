# encoding: utf-8
module Tourism::Model::Rel::Spot::Rel
  
  def rel_spots(options = {})
    docs = []
    ids = rel_spot_ids.to_s.split(' ').uniq
    return docs if ids.size == 0
    ids.each do |id|
      doc = Tourism::Doc.find_by_id(id, options)
      docs << doc if doc
    end
    docs
  end
  
  def in_rel_spot_ids
    unless val = @in_rel_spot_ids
      @in_rel_spot_ids = rel_spot_ids.to_s.split(' ').uniq)
    end
    @in_rel_spot_ids
  end
  
  def in_rel_spot_ids=(ids)
    _ids = []
    if ids.class == Array
      ids.each {|val| _ids << val}
      self.rel_spot_ids = _ids.join(' ')
    elsif ids.class == Hash || ids.class == HashWithIndifferentAccess
      ids.each {|key, val| _ids << val}
      self.rel_spot_ids = _ids.join(' ')
    else
      self.rel_spot_ids = ids
    end
  end
end