# encoding: utf-8
class Article::Admin::AreasController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content

    if params[:parent] == '0'
      @parent = Article::Area.new(level_no: 0)
      @parent.id = 0
    else
      @parent = Article::Area.find(params[:parent])
      return http_error(404) if @parent.level_no >= 4
    end
  end

  def index
    @items = Article::Area
             .where(content_id: @content)
             .where(parent_id: @parent)
             .order(:sort_no)
             .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Article::Area.find(params[:id])
    _show @item
  end

  def new
    @item = Article::Area.new(state: 'public',
                              sort_no: 1)
  end

  def create
    @item = Article::Area.new(areas_params)
    @item.parent_id = @parent.id
    @item.content_id = @content.id
    @item.level_no = @parent.level_no + 1
    _create @item
  end

  def update
    @item = Article::Area.find(params[:id])
    @item.attributes = areas_params
    _update @item
  end

  def destroy
    @item = Article::Area.find(params[:id])
    _destroy @item
  end

  private

  def areas_params
    params.require(:item).permit(
      :state, :concept_id, :layout_id, :name, :title, :zip_code,
      :address, :tel, :site_uri, :sort_no,
      in_creator: [:group_id, :user_id])
  end
end
