# encoding: utf-8
class Article::Public::Node::RecentDocsController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  helper Article::DocHelper

  def index
    @node    = Page.current_node
    @content = @node.content

    @docs = Article::Doc
            .published
            .agent_filter(request.mobile)
            .where(content_id: @content.id)
            .visible_in_recent
            .order(published_at: :desc)
            .paginate(page: params[:page],
                      per_page: (request.mobile? ? 20 : 50))
    return true if render_feed(@docs)

    if @docs.current_page > 1 && @docs.current_page > @docs.total_pages
      return http_error(404)
    end

    prev = nil
    @items = []
    @docs.each do |doc|
      next unless doc.published_at
      date = doc.published_at.strftime('%y%m%d')
      @items << {
        date: (date != prev ? doc.published_at.strftime('%Y年%-m月%-d日') : nil),
        doc: doc
      }
      prev = date
    end
  end
end
