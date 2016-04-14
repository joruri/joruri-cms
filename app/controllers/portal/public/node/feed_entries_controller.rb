# encoding: utf-8
class Portal::Public::Node::FeedEntriesController < Cms::Controller::Public::Base
  include Portal::Controller::Feed

  def pre_dispatch
    content = Page.current_node.content
    return http_error(404) unless content
    @content = Portal::Content::Base.find_by(id: content.id)
  end

  def index
    @entries = Portal::FeedEntry
               .public_content_with_own_docs(
                 @content,
                 :docs,
                 search: params,
                 mobile: request.mobile
               )
               .paginate(page: params[:page],
                         per_page: (request.mobile? ? 20 : 50))

    return true if render_feed(@entries)

    return http_error(404) if @entries.current_page > @entries.total_pages

    prev   = nil
    @items = []
    @entries.each do |entry|
      next unless entry.entry_updated
      date = entry.entry_updated.strftime('%y%m%d')
      @items << {
        date: (date != prev ? entry.entry_updated.strftime('%Y年%-m月%-d日') : nil),
        entry: entry
      }
      prev = date
    end
  end
end
