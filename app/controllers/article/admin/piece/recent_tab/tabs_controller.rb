# encoding: utf-8
class Article::Admin::Piece::RecentTab::TabsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    @piece = Cms::Piece.find(params[:piece])
    return error_auth unless @piece
    return error_auth unless @piece.editable?
    @content = @piece.content
    return error_auth unless @content
  end

  def index
    @items = Article::Piece::RecentTabXml.find(:all, @piece, order: :sort_no)
    _index @items
  end

  def show
    @item = Article::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    _show @item
  end

  def new
    @item = Article::Piece::RecentTabXml.new(@piece, sort_no: 0)
  end

  def create
    @item = Article::Piece::RecentTabXml.new(@piece, tab_params)
    _create @item
  end

  def update
    @item = Article::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    @item.attributes = tab_params
    _update @item
  end

  def destroy
    @item = Article::Piece::RecentTabXml.find(params[:id], @piece)
    _destroy @item
  end

  private

  def tab_params
    params.require(:item).permit(
      :name, :title, :more, :condition, :sort_no,
      unit: ['0','1','2'],
      category: ['0','1','2'],
      attribute: ['0','1','2'],
      area: ['0','1','2']
    )
  end
end
