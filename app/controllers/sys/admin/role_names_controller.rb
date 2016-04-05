# encoding: utf-8
class Sys::Admin::RoleNamesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end

  def index
    @items = Sys::RoleName
             .all
             .order(params[:sort], :name)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::RoleName.new.find(params[:id])
    _show @item
  end

  def new
    @item = Sys::RoleName.new({})
  end

  def create
    @item = Sys::RoleName.new(params[:item])
    _create @item
  end

  def update
    @item = Sys::RoleName.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Sys::RoleName.find(params[:id])
    _destroy @item
  end
end
