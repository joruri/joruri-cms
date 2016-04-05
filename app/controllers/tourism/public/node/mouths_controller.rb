# encoding: utf-8
class Tourism::Public::Node::MouthsController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper

  def pre_dispatch
    @content = Page.current_node.content
    return http_error(404) unless @content
  end

  def index
    @items = Tourism::Mouth
             .published
             .where(content_id: @content.id)
             .order(published_at: :desc)
             .paginate(page: params[:page],
                       per_page: (request.mobile? ? 10 : 20))

    return true if render_feed(@items)

    if @items.current_page > 1 && @items.current_page > @items.total_pages
      return http_error(404)
    end
  end

  def show
    @item = Tourism::Mouth
            .public_or_preview
            .where(content_id: Page.current_node.content.id)
            .where(name: params[:name])
            .first

    return http_error(404) unless @item

    Page.current_item = @item
    Page.title        = @item.title
  end
end
