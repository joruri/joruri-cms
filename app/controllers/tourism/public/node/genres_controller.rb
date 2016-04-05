# encoding: utf-8
class Tourism::Public::Node::GenresController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper

  def pre_dispatch
    @node     = Page.current_node
    @base_uri = @node.public_uri
    @content = @node.content
    return http_error(404) unless @content

    if params[:name]
      @item = Tourism::Genre
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
    @items = Tourism::Genre.root_items(content_id: @content.id, state: 'public')
  end

  def show
    @page  = params[:page]

    @items = Tourism::Genre
             .published
             .where(content_id: @content.id)
             .where(parent_id: @item.id)
             .order(:sort_no)

    @spots = Tourism::Spot
             .published
             .and_in_ssv(:genre_ids, @item.id)
             .order(:title_kana)
             .paginate(page: @page, per_page: (request.mobile? ? 20 : 60))
  end
end
