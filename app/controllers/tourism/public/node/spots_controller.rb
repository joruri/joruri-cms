# encoding: utf-8
class Tourism::Public::Node::SpotsController < Cms::Controller::Public::Base
  include Tourism::Controller::Feed
  helper Cms::EmbeddedFileHelper
  
  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @content = @node.content
  end
  
  def index
    item = Tourism::Spot.new.public
    item.and :content_id, @content.id
    item.search params
    item.page params[:page], (request.mobile? ? 10 : 60)
    @items = item.find(:all, :order => 'published_at DESC')
    
    return http_error(404) if @items.current_page > 1 && @items.current_page > @items.total_pages
  end

  def show
    item = Tourism::Spot.new.public_or_preview
    item.and :content_id, Page.current_node.content.id
    item.and :name, params[:name]
    return http_error(404) unless @item = item.find(:first)

    if Core.mode == 'preview' && params[:spot_id]
      cond = {:id => params[:spot_id], :content_id => @item.content_id, :name => @item.name}
      return http_error(404) unless @item = Tourism::Spot.find(:first, :conditions => cond)
    end
    
    Page.current_item = @item
    Page.title        = @item.title
    Page.add_body_class('spotDetail') if @item.has_detail_contents?
    
    @doc_content_id = @content.setting_value(:doc_content_id)
    if !@doc_content_id.blank?
      item = Article::Doc.new.public
      item.agent_filter(request.mobile)
      item.and :content_id, @doc_content_id
      item.visible_in_list
      item.tag_is @item.title
      item.page 1, (request.mobile? ? 10 : 60)
      @docs = item.find(:all, :order => 'published_at DESC')
    else
      @docs = {}
    end
    
    item = Tourism::Photo.new.public
    item.and :spot_id, @item.id
    item.page 1, 3
    @photos = item.find(:all, :order => 'published_at DESC')
    
    item = Tourism::Movie.new.public
    item.and :spot_id, @item.id
    item.page 1, 3
    @movies = item.find(:all, :order => 'published_at DESC')
    
    item = Tourism::Mouth.new.public
    item.and :spot_id, @item.id
    item.page 1, 5
    @mouths = item.find(:all, :order => 'published_at DESC')
    
    if Core.mode == 'preview' && !Core.publish
      if params[:spot_id]
        @item.body = @item.body.gsub(/(<img[^>]+src=".\/files\/.*?)(".*?>)/i, '\\1' + "?spot_id=#{params[:spot_id]}" + '\\2')
      end
    end
  end
end
