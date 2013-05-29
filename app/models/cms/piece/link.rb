# encoding: utf-8
class Cms::Piece::Link < Cms::Piece
  has_many :link_items, :foreign_key => :piece_id, :order => :sort_no,
    :class_name => 'Cms::PieceLinkItem', :dependent => :destroy
  
  def duplicate(rel_type = nil)
    dupe_item = super
    return false unless dupe_item
    
    link_items.each do |link|
      dupe_link = Cms::PieceLinkItem.new(link.attributes)
      dupe_link.piece_id   = dupe_item.id
      dupe_link.created_at = nil
      dupe_link.updated_at = nil
      dupe_link.save(:validate => false)
    end
    
    return dupe_item
  end
end