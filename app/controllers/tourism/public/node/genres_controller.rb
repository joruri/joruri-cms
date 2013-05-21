# encoding: utf-8
class Tourism::Public::Node::GenresController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper

  def pre_dispatch
    @node     = Page.current_node
    @base_uri = @node.public_uri
    return http_error(404) unless @content = @node.content
    
    if params[:name]
      item = Tourism::Genre.new.public
      item.and :content_id, @content.id
      item.and :name, params[:name]
      return http_error(404) unless @item = item.find(:first)
      Page.current_item = @item
      Page.title        = @item.title
    end
  end
  
  def index
    @items = Tourism::Genre.root_items(:content_id => @content.id, :state => 'public')
  end

  def show
    @page  = params[:page]
    
    item = Tourism::Genre.new.public
    item.and :content_id, @content.id
    item.and :parent_id, @item.id
    @items = item.find(:all, :order => :sort_no)
    
    spot = Tourism::Spot.new.public
    #spot.genre_is @item
    spot.and_in_ssv :genre_ids, @item.id
    spot.page @page, (request.mobile? ? 20 : 60)
    @spots = spot.find(:all, :order => :title_kana)
  end
end
