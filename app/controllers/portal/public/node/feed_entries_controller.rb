# encoding: utf-8
class Portal::Public::Node::FeedEntriesController < Cms::Controller::Public::Base
  include Portal::Controller::Feed

  def pre_dispatch
    return http_error(404) unless content = Page.current_node.content
    @content = Portal::Content::Base.find_by_id(content.id)
  end

  def index
    entry = Portal::FeedEntry.new.public
    entry.content_id = @content.id
    entry.agent_filter(request.mobile)
    entry.and "#{Cms::FeedEntry.table_name}.content_id", @content.id

    entry.search params
    entry.page params[:page], (request.mobile? ? 20 : 50)

    @entries = entry.find_with_own_docs(@content.doc_content, :docs)
    return true if render_feed(@entries)

    return http_error(404) if @entries.current_page > @entries.total_pages

    prev   = nil
    @items = []
    @entries.each do |entry|
      next unless entry.entry_updated
      date = entry.entry_updated.strftime('%y%m%d')
      @items << {
        :date => (date != prev ? entry.entry_updated.strftime('%Y年%-m月%-d日') : nil),
        :entry  => entry
      }
      prev = date
    end
  end
end
