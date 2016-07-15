# encoding: utf-8
class Portal::Admin::FeedsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Cms::Feed
             .where(content_id: @content.id)
             .order(params[:sort], id: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Cms::Feed.find(params[:id])
    _show @item
  end

  def new
    @item = Cms::Feed.new(state: 'public',
                          entry_count: 20)
  end

  def create
    @item = Cms::Feed.new(feed_params)
    @item.content_id = @content.id

    _create @item
  end

  def update
    @item = Cms::Feed.find(params[:id])
    @item.attributes = feed_params

    _update(@item)
  end

  def destroy
    @item = Cms::Feed.find(params[:id])
    _destroy @item
  end

  private

  def feed_params
    params.require(:item).permit(
      :state, :name, :title, :uri, :entry_count, :fixed_categories_xml,
      in_creator: [:group_id, :user_id])
  end
end
