# encoding: utf-8
require "rexml/document"
class Bbs::Admin::ItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Bbs::Content::Base.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    
    @node = @content.thread_node
    @node_uri = File.join(Core.site.full_uri, @node.public_uri) if @node
  end

  def index
    item = Bbs::Item.new.readable
    item.and :content_id, @content.id
    item.and :parent_id, 0
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at DESC'
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Bbs::Item.new.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    return error_auth
    @item = Bbs::Item.new({
      :concept_id => Core.concept(:id),
      :state      => 'public',
    })
  end
  
  def create
    return error_auth
    @item = Bbs::Item.new(params[:item])
    @item.state   = 'public'
    @item.site_id = Core.site.id
    _create @item
  end
  
  def update
    @item = Bbs::Item.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Bbs::Item.new.find(params[:id])
    _destroy @item
  end
end
