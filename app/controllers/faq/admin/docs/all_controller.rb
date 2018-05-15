# encoding: utf-8
class Faq::Admin::Docs::AllController < Faq::Admin::DocsController
  def index
    @items = Faq::Doc
             .where(content_id: @content.id)
             .search(params)
             .order(updated_at: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
end
