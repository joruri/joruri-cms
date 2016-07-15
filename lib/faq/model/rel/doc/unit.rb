# encoding: utf-8
module Faq::Model::Rel::Doc::Unit
  def date_and_unit
    separator = %(<span class="separator">　</span>)
    values = []
    values << %(<span class="date">#{published_at.strftime('%Y年%-m月%-d日')}</span>) if published_at
    values << %(<span class="unit">#{ERB::Util.html_escape(creator.group.name)}</span>) if creator && creator.group
    %(<span class="attributes">（#{values.join(separator)}）</span>).html_safe
  end

  def categories_and_unit
    cate = []
    category_items.each { |c| cate << c.title }
    separator = %(<span class="separator">　</span>)
    values = []
    values << %(<span class="category">#{ERB::Util.html_escape(cate.join('，'))}</span>) unless cate.empty?
    values << %(<span class="unit">#{ERB::Util.html_escape(creator.group.name)}</span>) if creator && creator.group
    %(<span class="attributes">（#{values.join(separator)}）</span>).html_safe
  end
end
