# encoding: utf-8
class Faq::Admin::Docs::AllController < Faq::Admin::DocsController
  def index
    item = Faq::Doc.new#.public#.readable
    #item.public unless Core.user.has_auth?(:manager)
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    _index @items
  end
end
