# encoding: utf-8
class Cms::Admin::ContentsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    # return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Cms::Content.search(params)
    @items = @items.readable if params[:s_target] != 'all'
    @items = @items.order(params[:sort], :name, :id)
                   .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Cms::Content.new.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::Content.new(concept_id: Core.concept(:id),
                             state: 'public')
  end

  def create
    @item = Cms::Content.new(params[:item])
    @item.state   = 'public'
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Cms::Content.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Cms::Content.new.find(params[:id])
    _destroy @item
  end
end
