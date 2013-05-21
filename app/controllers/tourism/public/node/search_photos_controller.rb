# encoding: utf-8
class Tourism::Public::Node::SearchPhotosController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper
  
  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content
  end
  
  def index
    @s_genre   = Tourism::Genre.find_by_id(params[:s_genre_id]) if params[:s_genre_id]
    @s_keyword = params[:s_keyword]
    
    item = Tourism::Photo.new.public
    item.and :content_id, @content.id
    
    size = item.condition.where.size
    item.search params
    if size == item.condition.where.size
      @nosearch = true
      @items    = []
      return
    end
    
    item.page params[:page], (request.mobile? ? 10 : 60)
    @items = item.find(:all, :order => 'published_at DESC')
  end
end
