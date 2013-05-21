# encoding: utf-8
class Sys::Admin::ObjectPrivilegesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @parent = Sys::RoleName.new.find(params[:parent])
  end
  
  def index
    item = Sys::ObjectPrivilege.new#.readable
    item.and :role_id, @parent.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'cms_concepts.name'
    joins = ["INNER JOIN cms_concepts ON cms_concepts.unid = sys_object_privileges.item_unid"]
    @items = item.find(:all, :group => :item_unid, :joins => joins)
    _index @items
  end
  
  def show
    @item = Sys::ObjectPrivilege.new.find(params[:id])
    #return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::ObjectPrivilege.new({
      :role_id => @parent.id
    })
  end
  
  def create
    @item = Sys::ObjectPrivilege.new(params[:item])
    @item.role_id    = @parent.id
    @item.in_actions = {} unless params[:item][:in_actions]
    _create @item
  end
  
  def update
    @item = Sys::ObjectPrivilege.new.find(params[:id])
    @item.attributes = params[:item]
    @item.in_actions = {} unless params[:item][:in_actions]
    _update @item
  end
  
  def destroy
    @item = Sys::ObjectPrivilege.new.find(params[:id])
    _destroy @item do
      @item.destroy_actions
    end
  end
end
