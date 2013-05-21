# encoding: utf-8
class Portal::Piece::RecentTabXml < Cms::Model::Base::PieceExtension
  set_model_name  "portal/piece/recent_tab"
  set_column_name :xml_properties
  set_node_xpath  "groups/group"
  set_primary_key :name

  attr_accessor :name
  attr_accessor :title
  attr_accessor :more
  attr_accessor :sort_no

  elem_accessor :category

  validates_presence_of :name, :title, :sort_no

  def category_items
    list = []
    category.each {|id| next unless i = Portal::Category.find_by_id(id); list << i }
    list
  end

end