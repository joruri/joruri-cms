# encoding: utf-8
class Portal::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content

    if params[:parent] == '0'
      @parent = Portal::Category.new(level_no: 0)
      @parent.id = 0
    else
      @parent = Portal::Category.find(params[:parent])
    end
  end

  def index
    @items = Portal::Category
             .where(parent_id: @parent)
             .order(params[:sort], :sort_no)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Portal::Category.find(params[:id])
    _show @item
  end

  def new
    @item = Portal::Category.new(state: 'public',
                                 sort_no: 1)
  end

  def create
    @item = Portal::Category.new(category_params)
    @item.content_id = @content.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1
    _create @item
  end

  def update
    @item = Portal::Category.find(params[:id])
    @item.attributes = category_params
    _update @item
  end

  def destroy
    @item = Portal::Category.find(params[:id])
    _destroy @item
  end

  private

  def category_params
    params.require(:item).permit(
      :state, :name, :title, :layout_id, :entry_categories, :sort_no,
      in_creator: [:group_id, :user_id])
  end
end
