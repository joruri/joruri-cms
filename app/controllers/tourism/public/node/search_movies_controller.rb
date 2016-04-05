# encoding: utf-8
class Tourism::Public::Node::SearchMoviesController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper

  def pre_dispatch
    @node = Page.current_node
    @content = @node.content
    return http_error(404) unless @content
  end

  def index
    if params[:s_genre_id]
      @s_genre = Tourism::Genre.find_by(id: params[:s_genre_id])
    end
    @s_keyword = params[:s_keyword]

    @items = Tourism::Movie
             .published
             .where(content_id: @content.id)

    size = @items.count

    @items = @items.search(params)

    if size == @items.count
      @nosearch = true
      @items    = []
      return
    end

    @items = @items.order(published_at: :desc)
                   .paginate(page: params[:page],
                             per_page: (request.mobile? ? 10 : 60))
  end
end
