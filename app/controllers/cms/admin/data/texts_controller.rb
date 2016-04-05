# encoding: utf-8
class Cms::Admin::Data::TextsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to action: 'index' if params[:reset]
  end

  def index
    @items = Cms::DataText.where(site_id: Core.site.id)
    @items = @items.readable if params[:s_target] != 'all'
    @items = @items.search(params)
                   .order(params[:sort], :name, :id)
                   .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Cms::DataText.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Cms::DataText.new(concept_id: Core.concept(:id),
                              state: 'public')
  end

  def create
    @item = Cms::DataText.new(texts_params)
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Cms::DataText.find(params[:id])
    @item.attributes = texts_params
    _update @item
  end

  def destroy
    @item = Cms::DataText.find(params[:id])
    _destroy @item
  end

  private

  def texts_params
    params.require(:item).permit(
      :concept_id, :state, :name, :title, :body,
      in_creator: [:group_id, :user_id]
    )
  end
end
