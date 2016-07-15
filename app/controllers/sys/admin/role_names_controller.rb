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
    @item = Sys::RoleName.find(params[:id])
    _show @item
  end

  def new
    @item = Sys::RoleName.new({})
  end

  def create
    @item = Sys::RoleName.new(role_name_params)
    _create @item
  end

  def update
    @item = Sys::RoleName.find(params[:id])
    @item.attributes = role_name_params
    _update @item
  end

  def destroy
    @item = Sys::RoleName.find(params[:id])
    _destroy @item
  end

  private

  def role_name_params
    params.require(:item).permit(:name, :title)
  end
end
