# encoding: utf-8
class Article::Admin::Docs::EditController < Article::Admin::DocsController
  def index
    @items = Article::Doc
             .where(content_id: @content.id)
             .editable
             .search(params)
             .order(updated_at: :desc)

    return download_csv if params[:csv].present?

    @items = @items.paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end
end
