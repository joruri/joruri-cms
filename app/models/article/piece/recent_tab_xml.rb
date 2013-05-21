# encoding: utf-8
class Article::Piece::RecentTabXml < Cms::Model::Base::PieceExtension
  set_model_name  "article/piece/recent_tab"
  set_column_name :xml_properties
  set_node_xpath  "groups/group"
  set_primary_key :name
  
  attr_accessor :name
  attr_accessor :title
  attr_accessor :more
  attr_accessor :condition
  attr_accessor :sort_no
  
  elem_accessor :unit
  elem_accessor :category
  elem_accessor :attribute
  elem_accessor :area
  
  validates_presence_of :name, :title, :sort_no
  
  def condition_states
    [['すべてを含む','and'], ['いずれかを含む', 'or']]
  end
  
  def condition_name
    no = condition =~ /and/ ? 0 : 1
    condition_states[no][0]
  end
  
  def unit_items
    list = []
    unit.each {|id| next unless i = Article::Unit.find_by_id(id); list << i }
    list
  end
  
  def category_items
    list = []
    category.each {|id| next unless i = Article::Category.find_by_id(id); list << i }
    list
  end
  
  def attribute_items
    list = []
    attribute.each {|id| next unless i = Article::Attribute.find_by_id(id); list << i }
    list
  end
  
  def area_items
    list = []
    area.each {|id| next unless i = Article::Area.find_by_id(id); list << i }
    list
  end
end