# encoding: utf-8
class Faq::Admin::Docs::PublishController < Faq::Admin::DocsController
  def index
    item = Faq::Doc.new.publishable
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    _index @items
  end
end
