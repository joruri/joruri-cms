# encoding: utf-8
class Faq::Public::Node::RecentDocsController < Cms::Controller::Public::Base
  include Faq::Controller::Feed

  def index
    @content = Page.current_node.content

    @docs = Faq::Doc
            .published
            .agent_filter(request.mobile)
            .where(content_id: @content.id)
            .visible_in_recent
            .order(published_at: :desc)
            .paginate(page: params[:page],
                      per_page: (request.mobile? ? 20 : 50))
    return true if render_feed(@docs)

    return http_error(404) if @docs.current_page > 1 && @docs.current_page > @docs.total_pages

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
