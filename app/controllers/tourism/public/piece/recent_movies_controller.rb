# encoding: utf-8
class Tourism::Public::Piece::RecentMoviesController < Sys::Controller::Public::Base
  helper Cms::EmbeddedFileHelper
  
  def index
    @piece   = Page.current_piece
    @content = Tourism::Content::Spot.find(@piece.content_id)
    
    limit = @piece.setting_value(:list_count)
    limit = (limit.to_s =~ /^[1-9][0-9]*$/) ? limit.to_i : 10
    
    item = Tourism::Movie.new.public
    item.and :content_id, @content.id
    item.page 1, limit
    
    @items = item.find(:all, :order => 'published_at DESC')
  end
end
