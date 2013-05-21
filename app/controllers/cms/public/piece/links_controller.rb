# encoding: utf-8
class Cms::Public::Piece::LinksController < Sys::Controller::Public::Base
  def index
    @piece = Cms::Piece::Link.find(Page.current_piece.id)
  end
end
