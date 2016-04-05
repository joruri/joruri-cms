# encoding: utf-8
class Sys::Admin::GroupsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    id = params[:parent] == '0' ? 1 : params[:parent]
    @parent = Sys::Group.new.find(id)

    @groups = Sys::Group
              .readable
              .where(parent_id: @parent.id)
              .order(:sort_no, :code, :id)

    @users = Sys::User
             .readable
             .joins(:groups)
             .where(Sys::Group.arel_table[:id].eq(@parent))
             .order(params[:sort], "LPAD(account, 15, '0')")
  end

  def index
    @items = Sys::Group
             .readable
             .where(parent_id: @parent.id)
             .order(params[:sort], :id)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::Group.find(params[:id])
    return error_auth unless @item.readable?
    _show @item
  end

  def new
    @item = Sys::Group.new(state: 'enabled',
                           parent_id: @parent.id,
                           ldap: 0,
                           web_state: 'public')
  end

  def create
    @item = Sys::Group.new(params[:item])
    parent = Sys::Group.find_by(id: @item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _create @item
  end

  def update
    @item = Sys::Group.find(params[:id])
    @item.attributes = params[:item]
    parent = Sys::Group.find_by(id: @item.parent_id)
    @item.level_no = parent ? parent.level_no + 1 : 1
    _update @item
  end

  def destroy
    @item = Sys::Group.find(params[:id])
    _destroy @item
  end
end
