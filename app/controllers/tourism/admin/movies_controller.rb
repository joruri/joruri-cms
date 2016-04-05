# encoding: utf-8
class Tourism::Admin::MoviesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  helper Cms::EmbeddedFileHelper
  helper Tourism::FormHelper

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item = Tourism::Movie.new(params.reject { |k, _v| k.to_s !~ /^s_/ })

    @items = Tourism::Movie
             .where(content_id: @content)
             .search(params)
             .order(params[:sort] || updated_at: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Tourism::Movie.find(params[:id])
    _show @item
  end

  def new
    @item = Tourism::Movie.new(state: 'public',
                               content_id: @content.id)
  end

  def create
    @item = Tourism::Movie.new(params[:item])
    @item.content_id = @content.id
    _create @item
  end

  def update
    @item = Tourism::Movie.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Tourism::Movie.find(params[:id])
    _destroy @item
  end
end
