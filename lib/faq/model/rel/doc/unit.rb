# encoding: utf-8
module Faq::Model::Rel::Doc::Unit
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
end