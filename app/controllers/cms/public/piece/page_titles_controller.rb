# encoding: utf-8
class Cms::Public::Piece::PageTitlesController < Sys::Controller::Public::Base
  def index
    @title = Page.title
  end
end
