# encoding: utf-8
class Sys::Admin::LanguagesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    item = Sys::Language.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Sys::Language.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Sys::Language.new({
      :state      => 'enabled',
    })
  end
  
  def create
    @item = Sys::Language.new(params[:item])
    _create @item
  end
  
  def update
    @item = Sys::Language.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end
  
  def destroy
    @item = Sys::Language.new.find(params[:id])
    _destroy @item
  end
end
