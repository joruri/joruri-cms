# encoding: utf-8
class Article::Public::Node::RecentDocsController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  helper Article::DocHelper
  
  def index
    @node    = Page.current_node
    @content = @node.content
    
    doc = Article::Doc.new.public
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
