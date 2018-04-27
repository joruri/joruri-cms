# encoding: utf-8
class Article::Admin::UnitsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content

    @parent = if params[:parent].to_s == '0'
                Article::Unit.root_item
              else
                Article::Unit.find(params[:parent])
              end
  end

  def index
    @items = Article::Unit
             .where(parent_id: @parent.id)
             .paginate(page: params[:page], per_page: params[:limit])
             .order(:sort_no)

    _index @items
  end

  def show
    @item = Article::Unit.find(params[:id])
    _show @item
  end

  def new
    @item = Article::Unit.new(state: 'public',
                              parent_code: @parent.code,
                              level_no: @parent.level_no + 1,
                              sort_no: 1)
  end

  def create
    @item = Article::Unit.new(units_params)
    @item.content_id = @content.id
    _create @item
  end

  def update
    @item = Article::Unit.find(params[:id])
    @item.attributes = units_params
    _update @item
  end

  def destroy
    @item = Article::Unit.find(params[:id])
    _destroy @item
  end

  private

  def units_params
    params.require(:item).permit(
      :web_state, :layout_id, :email, :tel, :outline_uri)
  end
end
