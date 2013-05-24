# encoding: utf-8
class Sys::Admin::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = Sys::Group.new.find(id)
    
    item = Sys::Group.new.readable
    item.and :parent_id, @parent.id
    #item.page  params[:page], params[:limit]
    @groups = item.find(:all, :order => 'sort_no, code, id')
    
    item = Sys::User.new.readable
    item.join :groups
    item.and 'sys_groups.id', @parent
    #item.search params
    #item.page  params[:page], params[:limit]
    item.order params[:sort], "LPAD(account, 15, '0')"
    @users = item.find(:all)
  end
  
  def index
    item = Sys::Group.new.readable
    item.and :parent_id, @parent.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], :id
    @items = item.find(:all)
    _index @items
  end
  
  def show
    @item = Sys::Group.new.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::Group.new({
      :state      => 'enabled',
      :parent_id  => @parent.id,
      :ldap       => 0,
      :web_state  => 'public'
    })
  end
  
  def create
    @item = Sys::Group.new(params[:item])
    #@item.parent_id = @parent.id
    parent = Sys::Group.find_by_id(@item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _create @item
  end
  
  def update
    @item = Sys::Group.new.find(params[:id])
    @item.attributes = params[:item]
    parent = Sys::Group.find_by_id(@item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _update @item
  end
  
  def destroy
    @item = Sys::Group.new.find(params[:id])
    _destroy @item
  end
end
