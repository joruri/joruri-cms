# encoding: utf-8
class Faq::Public::Node::RecentDocsController < Cms::Controller::Public::Base
  include Faq::Controller::Feed
  
  def index
    @content = Page.current_node.content
    
    doc = Faq::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, @content.id
    doc.visible_in_recent
    #doc.search params
    doc.page params[:page], (request.mobile? ? 20 : 50)
    @docs = doc.find(:all, :order => 'published_at DESC')
    return true if render_feed(@docs)
    
    return http_error(404) if @docs.current_page > 1 && @docs.current_page > @docs.total_pages
    
    prev = nil
    @items = []
    @docs.each do |doc|
      next unless doc.published_at
      date = doc.published_at.strftime('%y%m%d')
      @items << {
        :date => (date != prev ? doc.published_at.strftime('%Y年%-m月%-d日') : nil),
        :doc  => doc
      }
      prev = date    
    end
  end
end
