# encoding: utf-8
class Portal::Public::Node::CategoriesController < Cms::Controller::Public::Base
  include Portal::Controller::Feed

  def pre_dispatch
    content = Page.current_node.content
    return http_error(404) unless content

    @content = Portal::Content::Base.find_by(id: content.id)
    return http_error(404) unless @content

    @entries_uri = @content.public_uri('Portal::FeedEntry')

    @limit = 50

    if params[:name]
      @item = Portal::Category
              .published
              .where(content_id: @content.id)
              .where(name: params[:name])
              .first
      return http_error(404) unless @item

      Page.current_item = @item
      Page.title        = @item.title
    end
  end

  def index
    @items = Portal::Category.root_items(content_id: @content.id, state: 'public')
  end

  def show
    return http_error(404) unless params[:file] =~ /^index$/

    @page = params[:page]

    @entries = Portal::FeedEntry
               .public_content_with_own_docs(
                  @content,
                  :groups,
                  category: @item,
                  mobile: request.mobile)
               .paginate(page: @page, per_page: @limit)

    return true if render_feed(@entries)

    if @entries.current_page > 1 && @entries.current_page > @entries.total_pages
      return http_error(404)
    end

    prev   = nil
    @items = []
    @entries.each do |entry|
      date = entry.entry_updated.strftime('%y%m%d')
      @items << {
        date: (date != prev ? entry.entry_updated.strftime('%Y年%-m月%-d日') : nil),
        entry: entry
      }
      prev = date
    end
  end
end
