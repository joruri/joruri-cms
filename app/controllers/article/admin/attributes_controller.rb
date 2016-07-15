# encoding: utf-8
class Article::Admin::AttributesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    @parent = 0
  end

  def index
    @items = Article::Attribute
             .where(content_id: @content)
             .order(params[:sort], :sort_no)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Article::Attribute.find(params[:id])
    _show @item
  end

  def new
    @item = Article::Attribute.new(state: 'public',
                                   sort_no: 1)
  end

  def create
    @item = Article::Attribute.new(attributes_params)
    @item.content_id = @content.id
    _create @item
  end

  def update
    @item = Article::Attribute.find(params[:id])
    @item.attributes = attributes_params
    _update @item
  end

  def destroy
    @item = Article::Attribute.find(params[:id])
    _destroy @item
  end

  private

  def attributes_params
    params.require(:item).permit(
      :state, :concept_id, :layout_id, :name, :title, :sort_no,
      in_creator: [:group_id, :user_id])
  end
end
