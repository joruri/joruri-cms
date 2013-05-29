# encoding: utf-8
class Faq::Public::Piece::RecentDocsController < Sys::Controller::Public::Base
  def index
    @content = Faq::Content::Doc.find(Page.current_piece.content_id)
    @node    = @content.recent_node
    @piece   = Page.current_piece
    
    @more_label = @piece.setting_value(:more_label)
    @more_label = ">>新着記事一覧" if @more_label.blank?
    
    limit = Page.current_piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10
    
    doc = Faq::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, @content.id
    doc.visible_in_recent
    doc.page 1, limit
    @docs = doc.find(:all, :order => 'published_at DESC')
    
    prev   = nil
    @items = []
    @docs.each do |doc|
      date = doc.published_at.strftime('%y%m%d')
      @items << {
        :date => (date != prev ? doc.published_at.strftime('%Y年%-m月%-d日') : nil),
        :doc  => doc
      }
      prev = date    
    end
  end
end
