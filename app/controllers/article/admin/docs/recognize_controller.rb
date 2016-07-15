# encoding: utf-8
class Article::Admin::Docs::RecognizeController < Article::Admin::DocsController
  def index
    @items = Article::Doc.where(content_id: @content.id)

    if @recognition_type == 'with_admin' && Core.user.has_auth?(:manager)
      @items = @items.recognizable_with_admin
    else
      @items = @items.recognizable
    end

    @items = @items.search(params)
                   .order(params[:sort], updated_at: :desc)
                   .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
end
