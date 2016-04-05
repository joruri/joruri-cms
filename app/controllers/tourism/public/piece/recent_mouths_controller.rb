# encoding: utf-8
class Tourism::Public::Piece::RecentMouthsController < Sys::Controller::Public::Base
  helper Cms::EmbeddedFileHelper

  def index
    @piece   = Page.current_piece
    @content = Tourism::Content::Spot.find(@piece.content_id)

    limit = @piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10

    @items = Tourism::Mouth
             .published
             .where(content_id: @content.id)
             .order(published_at: :desc)
             .paginate(page: 1, per_page: limit)
  end
end
