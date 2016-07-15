# encoding: utf-8
class Article::Admin::Docs::AllController < Article::Admin::DocsController
  def index
    @items = Article::Doc.where(content_id: @content.id)
                         .search(params)
                         .order(params[:sort], updated_at: :desc)
                         .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
end
