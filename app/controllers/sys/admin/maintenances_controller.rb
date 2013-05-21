# encoding: utf-8
class Sys::Admin::MaintenancesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    item = Sys::Maintenance.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'published_at DESC'
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Sys::Maintenance.new.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Sys::Maintenance.new({
      :state        => 'public',
      :published_at => Core.now,
    })
  end
  
  def create
    @item = Sys::Maintenance.new(params[:item])
    _create @item
  end
  
  def update
    @item = Sys::Maintenance.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Sys::Maintenance.new.find(params[:id])
    _destroy @item
  end
end
