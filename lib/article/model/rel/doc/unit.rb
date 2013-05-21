# encoding: utf-8
module Article::Model::Rel::Doc::Unit
  def date_and_unit
    separator = %Q(<span class="separator">　</span>)
    values = []
    values << %Q(<span class="date">#{published_at.strftime('%Y年%-m月%-d日')}</span>) if published_at
    values << %Q(<span class="unit">#{ERB::Util.html_escape(creator.group.name)}</span>) if creator && creator.group
    %Q(<span class="attributes">（#{values.join(separator)}）</span>).html_safe
  end
  
  def categories_and_unit
    cate = []
    category_items.each {|c| cate << c.title }
    separator = %Q(<span class="separator">　</span>)
    values = []
    values << %Q(<span class="category">#{ERB::Util.html_escape(cate.join('，'))}</span>) if cate.size > 0
    values << %Q(<span class="unit">#{ERB::Util.html_escape(creator.group.name)}</span>) if creator && creator.group
    %Q(<span class="attributes">（#{values.join(separator)}）</span>).html_safe
  end
  
  def unit_is(unit)
    return self if unit.blank?
    unit = [unit] unless unit.class == Array
    unit.each do |c|
      if c.level_no == 2
        unit += c.public_children
      end
    end
    unit = unit.uniq
    
    join_creator
    self.and 'sys_creators.group_id', 'IN', unit
    self
  end

  def unit
    return nil unless creator
    return nil if creator.group_id.blank?
    Article::Unit.find_by_id(creator.group_id)
  end
end