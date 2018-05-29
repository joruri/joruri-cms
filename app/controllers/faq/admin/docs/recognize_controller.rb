# encoding: utf-8
class Faq::Admin::Docs::RecognizeController < Faq::Admin::DocsController
  def index
    @items = Faq::Doc.where(content_id: @content.id)

    if @recognition_type == 'with_admin' && Core.user.has_auth?(:manager)
      @items = @items.recognizable_with_admin
    else
      @items = @items.recognizable
    end

    @items = @items.search(params)
                   .order(updated_at: :desc)
                   .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end
end
