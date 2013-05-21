# encoding: utf-8
class EntityConversion::Admin::TestsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    
    @log = EntityConversion::Log.find(:first, :conditions => {:content_id => @content.id, :env => :test})

    return redirect_to :action => 'index' if params[:reset]
  end
  
  def index
    return test if params[:do] == "test"
    
    @item = EntityConversion::Unit.new
    
    item = EntityConversion::Unit.new
    item.and :content_id, @content.id
    item.and :state, "new"
    @new_items = item.find(:all, :order => :sort_no)
    
    item = EntityConversion::Unit.new
    item.and :content_id, @content.id
    item.and :state, "edit"
    @edit_items = item.find(:all, :order => :sort_no)
    
    item = EntityConversion::Unit.new
    item.and :content_id, @content.id
    item.and :state, "move"
    @move_items = item.find(:all, :order => :sort_no)
    
    item = EntityConversion::Unit.new
    item.and :content_id, @content.id
    item.and :state, "end"
    @end_items = item.find(:all, :order => "old_parent_id, old_id")
    
    #_index @items
  end
  
protected
  
  def test
    conv = EntityConversion::Lib::Convertor.factory(:test, :content => @content)
    conv.convert
    redirect_to url_for(:action => :index)
  end
end
