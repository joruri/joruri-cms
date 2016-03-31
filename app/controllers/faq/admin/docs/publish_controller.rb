# encoding: utf-8
class Faq::Admin::Docs::PublishController < Faq::Admin::DocsController
  def index
    @items = Faq::Doc
             .publishable
             .where(content_id: @content.id)
             .search(params)
             .order(params[:sort], updated_at: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
end
