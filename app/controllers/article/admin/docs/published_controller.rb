# encoding: utf-8
class Article::Admin::Docs::PublishedController < Article::Admin::DocsController
  def index
    @items = Article::Doc.published.where(content_id: @content.id)
                         .search(params)
                         .order(updated_at: :desc)
                         .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
end
