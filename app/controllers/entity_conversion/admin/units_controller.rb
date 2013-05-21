# encoding: utf-8
class EntityConversion::Admin::UnitsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    
    return redirect_to :action => 'index' if params[:reset]
  end
  
  def index
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
  
  def show
    @item = EntityConversion::Unit.new.find(params[:id])
    _show @item
  end

  def new
    @item = EntityConversion::Unit.new({
      :ldap      => 1,
      :sort_no   => 0,
      :web_state => 'public',
    })
  end
  
  def create
    @item = EntityConversion::Unit.new(params[:item])
    @item.content_id = @content.id
    
    if params[:sync]
      sync(@item)
      return render(:new) 
    end
    
    _create @item, :location => entity_conversion_units_path
  end
  
  def update
    @item = EntityConversion::Unit.new.find(params[:id])
    @item.attributes = params[:item]
    
    if params[:sync]
      sync(@item)
      return render(:edit) 
    end
    
    _update @item, :location => entity_conversion_units_path
  end
  
  def destroy
    @item = EntityConversion::Unit.new.find(params[:id])
    
    _destroy @item, :location => entity_conversion_units_path
  end
  
protected
  
  def sync(item)
    return false if item.old_id.blank?
    
    group = Sys::Group.find_by_id(item.old_id)
    return false unless group
    
    item.code        = group.code
    item.name        = group.name
    item.name_en     = group.name_en
    item.ldap        = group.ldap
    item.sort_no     = group.sort_no
    item.web_state   = group.web_state
    item.layout_id   = group.layout_id
    item.email       = group.email
    item.tel         = group.tel
    item.outline_uri = group.outline_uri
    
    return true
  end
end
