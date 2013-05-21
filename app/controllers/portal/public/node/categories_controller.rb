# encoding: utf-8
class Portal::Public::Node::CategoriesController < Cms::Controller::Public::Base
  include Portal::Controller::Feed

  def pre_dispatch
    return http_error(404) unless content = Page.current_node.content
    return http_error(404) unless @content = Portal::Content::Base.find_by_id(content.id)
    @entries_uri = @content.public_uri('Portal::FeedEntry')

    @limit = 50

    if params[:name]
      item = Portal::Category.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end

  def index
    @items = Portal::Category.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    return http_error(404) unless params[:file] =~ /^index$/

    @page  = params[:page]
    
    entry = Portal::FeedEntry.new.public
    entry.content_id = @content.id
    entry.agent_filter(request.mobile)
    entry.and "#{Cms::FeedEntry.table_name}.content_id", @content.id
    entry.category_is @item
    entry.page @page, @limit
    entry.page @page, @limit
    @entries = entry.find_with_own_docs(@content.doc_content, :groups, {:item => @item})
    return true if render_feed(@entries)

    return http_error(404) if @entries.current_page > 1 && @entries.current_page > @entries.total_pages

    prev   = nil
    @items = []
    @entries.each do |entry|
      date = entry.entry_updated.strftime('%y%m%d')
      @items << {
        :date => (date != prev ? entry.entry_updated.strftime('%Y年%-m月%-d日') : nil),
        :entry  => entry
      }
      prev = date
    end
  end
end
