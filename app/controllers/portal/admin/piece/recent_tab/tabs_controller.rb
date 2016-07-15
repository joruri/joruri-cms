# encoding: utf-8
class Portal::Admin::Piece::RecentTab::TabsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  # simple_layout

  def pre_dispatch
    @piece = Cms::Piece.find(params[:piece])
    return error_auth unless @piece
    return error_auth unless @piece.editable?
    @content = @piece.content
    return error_auth unless @content
  end

  def index
    @items = Portal::Piece::RecentTabXml.find(:all, @piece, order: :sort_no)
    _index @items
  end

  def show
    @item = Portal::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    _show @item
  end

  def new
    @item = Portal::Piece::RecentTabXml.new(@piece, sort_no: 0)
  end

  def create
    @item = Portal::Piece::RecentTabXml.new(@piece, tab_params)
    _create @item
  end

  def update
    @item = Portal::Piece::RecentTabXml.find(params[:id], @piece)
    return error_auth unless @item
    @item.attributes = tab_params
    _update @item
  end

  def destroy
    @item = Portal::Piece::RecentTabXml.find(params[:id], @piece)
    _destroy @item
  end

  private

  def tab_params
    params.require(:item).permit(
      :name, :title, :more, :sort_no, category: ['0']
    )
  end
end
