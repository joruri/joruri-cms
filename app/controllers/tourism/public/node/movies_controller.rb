# encoding: utf-8
class Tourism::Public::Node::MoviesController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed

  def pre_dispatch
    @node = Page.current_node
    @content = @node.content
    return http_error(404) unless @content
  end

  def index
    @items = Tourism::Movie
             .published
             .where(content_id: @content.id)
             .order(published_at: :desc)
             .paginate(page: params[:page],
                       per_page: (request.mobile? ? 10 : 60))
    return true if render_feed(@items)

    if @items.current_page > 1 && @items.current_page > @items.total_pages
      return http_error(404)
    end
  end

  def show
    @item = Tourism::Movie
            .public_or_preview
            .where(content_id: Page.current_node.content.id)
            .where(name: params[:name])
            .first
    return http_error(404) unless @item

    Page.current_item = @item
    Page.title        = @item.title

    if @node.setting_value(:show_concept_id)
      @item.concept_id = @node.setting_value(:show_concept_id)
    end

    if @node.setting_value(:show_layout_id)
      @item.layout_id  = @node.setting_value(:show_layout_id)
    end
  end
end
