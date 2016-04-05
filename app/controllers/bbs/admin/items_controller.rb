# encoding: utf-8
require 'rexml/document'
class Bbs::Admin::ItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Bbs::Content::Base.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @node = @content.thread_node
    @node_uri = File.join(Core.site.full_uri, @node.public_uri) if @node
  end

  def index
    @items = Bbs::Item
             .readable
             .where(content_id: @content.id)
             .where(parent_id: 0)
             .search(params)
             .order(params[:sort], updated_at: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Bbs::Item.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    return error_auth
    @item = Bbs::Item.new(concept_id: Core.concept(:id),
                          state: 'public')
  end

  def create
    return error_auth
    @item = Bbs::Item.new(item_params)
    @item.state   = 'public'
    @item.site_id = Core.site.id
    _create @item
  end

  def update
    @item = Bbs::Item.find(params[:id])
    @item.attributes = item_params
    _update @item
  end

  def destroy
    @item = Bbs::Item.find(params[:id])
    _destroy @item
  end

  private

  def item_params
    params.require(:item).permit(:state, :name, :title, :body, :email, :uri)
  end
end
