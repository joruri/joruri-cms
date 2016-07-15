# encoding: utf-8
class Newsletter::Admin::TestersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    @items = Newsletter::Tester
             .where(content_id: @content.id)
             .order(params[:sort], :email)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Newsletter::Tester.find(params[:id])
    _show @item
  end

  def new
    @item = Newsletter::Tester.new(state: 'enabled',
                                   agent_state: 'pc')
  end

  def create
    @item = Newsletter::Tester.new(tester_params)
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Newsletter::Tester.find(params[:id])
    @item.attributes = tester_params

    _update(@item)
  end

  def destroy
    @item = Newsletter::Tester.find(params[:id])
    _destroy @item
  end

  private

  def tester_params
    params.require(:item).permit(
      :state, :email, :agent_state, :name,
      in_creator: [:group_id, :user_id])
  end
end
