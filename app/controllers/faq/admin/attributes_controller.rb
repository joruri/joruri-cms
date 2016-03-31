# encoding: utf-8
class Faq::Admin::AttributesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    @parent = 0
  end

  def index
    @items = Faq::Attribute
             .where(content_id: @content)
             .order(params[:sort], :sort_no)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Faq::Attribute.find(params[:id])
    _show @item
  end

  def new
    @item = Faq::Attribute.new(state: 'public',
                               sort_no: 1)
  end

  def create
    @item = Faq::Attribute.new(params[:item])
    @item.content_id = @content.id
    _create @item
  end

  def update
    @item = Faq::Attribute.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Faq::Attribute.find(params[:id])
    _destroy @item
  end
end
