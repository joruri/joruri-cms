# encoding: utf-8
class Enquete::Admin::FormsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  helper Article::FormHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Enquete::Form
             .where(content_id: @content.id)
             .order(:sort_no, id: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Enquete::Form.find(params[:id])

    _show @item
  end

  def new
    @item = Enquete::Form.new(state: 'public', sort_no: 0)
  end

  def create
    @item = Enquete::Form.new(form_params)
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Enquete::Form.find(params[:id])
    @item.attributes = form_params

    _update(@item)
  end

  def destroy
    @item = Enquete::Form.find(params[:id])
    _destroy @item
  end

  private

  def form_params
    params.require(:item).permit(
      :state, :name, :summary, :body, :sent_body, :sort_no,
      in_creator: [:group_id, :user_id]
    )
  end
end
