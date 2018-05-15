# encoding: utf-8
class Article::Admin::Docs::EditController < Article::Admin::DocsController
  def index
    @items = Article::Doc
             .where(content_id: @content.id)
             .editable
             .search(params)
             .paginate(page: params[:page], per_page: params[:limit])
             .order(updated_at: :desc)

    _index @items
  end
end
