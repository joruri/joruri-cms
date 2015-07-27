# encoding: utf-8
class Cms::Admin::Data::TextsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return redirect_to :action => 'index' if params[:reset]
  end
  
  def index
    item = Cms::DataText.new
    item.readable if params[:s_target] != "all"
    item.and :site_id, Core.site.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'name, id'
    @items = item.find(:all)
    _index @items
  end
  
  def show
    item = Cms::DataText.new.readable
    @item = item.find(params[:id])
    return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Cms::DataText.new({
      :concept_id => Core.concept(:id),
      :state      => 'public',
    })
  end
  
  def create
    @item = Cms::DataText.new(params[:item])
    @item.site_id = Core.site.id
    _create @item
  end
  
  def update
    @item = Cms::DataText.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Cms::DataText.new.find(params[:id])
    _destroy @item
  end
end
