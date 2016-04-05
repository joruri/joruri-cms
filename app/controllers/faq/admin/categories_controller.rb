# encoding: utf-8
class Faq::Admin::CategoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content

    if params[:parent] == '0'
      @parent = Faq::Category.new(level_no: 0)
      @parent.id = 0
    else
      @parent = Faq::Category.find(params[:parent])
    end
  end

  def index
    @items = Faq::Category
             .where(parent_id: @parent)
             .where(content_id: @content)
             .order(params[:sort], :sort_no)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Faq::Category.find(params[:id])
    _show @item
  end

  def new
    @item = Faq::Category.new(state: 'public',
                              sort_no: 1)
  end

  def create
    @item = Faq::Category.new(categories_params)
    @item.content_id = @content.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1
    _create @item
  end

  def update
    @item = Faq::Category.find(params[:id])
    @item.attributes = categories_params
    _update @item
  end

  def destroy
    @item = Faq::Category.find(params[:id])
    _destroy @item
  end

  private

  def categories_params
    params.require(:item).permit(
      :state, :concept_id, :layout_id, :name, :title, :sort_no,
      in_creator: [:group_id, :user_id])
  end
end
