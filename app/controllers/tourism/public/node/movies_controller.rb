# encoding: utf-8
class Tourism::Public::Node::MoviesController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  
  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content
  end
  
  def index
    item = Tourism::Movie.new.public
    item.and :content_id, @content.id
    #item.search params
    item.page params[:page], (request.mobile? ? 10 : 60)
    @items = item.find(:all, :order => 'published_at DESC')
    return true if render_feed(@items)
    
    return http_error(404) if @items.current_page > 1 && @items.current_page > @items.total_pages
  end

  def show
    item = Tourism::Movie.new.public_or_preview
    item.and :content_id, Page.current_node.content.id
    item.and :name, params[:name]
    return http_error(404) unless @item = item.find(:first)

    Page.current_item = @item
    Page.title        = @item.title
    
    @item.concept_id = @node.setting_value(:show_concept_id) if @node.setting_value(:show_concept_id)
    @item.layout_id  = @node.setting_value(:show_layout_id) if @node.setting_value(:show_layout_id)
  end
end
