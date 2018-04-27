# encoding: utf-8
class Sys::Admin::ObjectPrivilegesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    @parent = Sys::RoleName.find(params[:parent])
  end

  def index
    @items = Sys::ObjectPrivilege
             .where(role_id: @parent.id)
             .joins(:concept)
             .group(:item_unid)
             .order(Cms::Concept.arel_table[:name])
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::ObjectPrivilege.find(params[:id])
    _show @item
  end

  def new
    @item = Sys::ObjectPrivilege.new(role_id: @parent.id)
  end

  def create
    @item = Sys::ObjectPrivilege.new(object_privilege_params)
    @item.role_id    = @parent.id
    @item.in_actions = {} unless params[:item][:in_actions]
    _create @item
  end

  def update
    @item = Sys::ObjectPrivilege.find(params[:id])
    @item.attributes = object_privilege_params
    @item.in_actions = {} unless params[:item][:in_actions]
    _update @item
  end

  def destroy
    @item = Sys::ObjectPrivilege.find(params[:id])
    _destroy @item do
      @item.destroy_actions
    end
  end

  private

  def object_privilege_params
    params.require(:item).permit(
      :item_unid, in_actions: [:read, :create, :update, :delete])
  end
end
