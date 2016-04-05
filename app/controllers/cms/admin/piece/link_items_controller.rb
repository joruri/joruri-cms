# encoding: utf-8
class Cms::Admin::Piece::LinkItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    @piece = Cms::Piece.new.readable.find(params[:piece])
    return error_auth unless @piece
  end

  def index
    @items = Cms::PieceLinkItem
             .where(piece_id: @piece.id)
             .order(params[:sort], :sort_no)
    _index @items
  end

  def show
    @item = Cms::PieceLinkItem.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Cms::PieceLinkItem.new(piece_id: @piece.id,
                                   state: 'public',
                                   sort_no: 0)
  end

  def create
    @item = Cms::PieceLinkItem.new(params[:item])
    @item.piece_id = @piece.id
    _create @item
  end

  def update
    @item = Cms::PieceLinkItem.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Cms::PieceLinkItem.find(params[:id])
    _destroy @item
  end
  
  private

  def link_item_params
    params.require(:item).permit(:state, :name, :uri, :target, :sort_no)
  end
end
