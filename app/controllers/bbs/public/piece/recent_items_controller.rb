# encoding: utf-8
class Bbs::Public::Piece::RecentItemsController < Sys::Controller::Public::Base
  def index
    @content  = Bbs::Content::Base.find(Page.current_piece.content_id)
    @node     = @content.thread_node
    @node_uri = @node.public_uri
    
    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10
    
    item = Bbs::Item.new.public
    item.and :content_id, @content.id
    case Page.current_piece.setting_value(:list_type).to_s
    when "1"
      item.and :parent_id, 0
    when "2"
      item.and :parent_id, "!=", 0
    end
    item.page 1, limit
    @items = item.find(:all, :order => 'id DESC')
    
    ## for mobile
    @dates = []
    prev   = nil
    @items.each do |item|
      date = item.created_at.strftime('%y%m%d')
      @dates << {
        :date => (date != prev ? item.created_at.strftime('%Y年%-m月%-d日') : nil),
        :item => item
      }
      prev = date    
    end
  end
end
