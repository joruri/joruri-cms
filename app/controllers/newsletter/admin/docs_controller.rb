# encoding: utf-8
class Newsletter::Admin::DocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Newsletter::MailHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @content = Newsletter::Content::Base.find_by(id: params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Newsletter::Doc
             .where(content_id: @content.id)
             .search(params)
             .order(params[:sort], id: :desc)
             .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Newsletter::Doc.find(params[:id])
    _show @item
  end

  def new
    @item = Newsletter::Doc.new(state: 'disabled')
    if @content.template_state == 'enabled'
      @item.body        = @content.template if @content.template
      @item.mobile_body = @content.template_mobile if @content.template_mobile
    end
  end

  def create
    @item = Newsletter::Doc.new(doc_params)
    @item.content_id     = @content.id
    @item.delivery_state = 'yet'

    _create @item
  end

  def update
    @item = Newsletter::Doc.find(params[:id])
    @item.attributes = doc_params

    _update(@item)
  end

  def destroy
    @item = Newsletter::Doc.find(params[:id])
    _destroy @item
  end

  private

  def doc_params
    params.require(:item).permit(
      :state, :title, :body, :mobile_title, :mobile_body,
      in_creator: [:group_id, :user_id])
  end
end
