# encoding: utf-8
class Sys::Admin::GroupUsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = Sys::Group.find(id)
  end

  def index
    redirect_to(sys_groups_path(@parent))
  end

  def show
    @item = Sys::User.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Sys::User.new(state: 'enabled',
                          ldap: '0',
                          auth_no: 2,
                          in_group_id: @parent.id)
  end

  def create
    @item = Sys::User.new(group_user_params)
    _create(@item, location: sys_groups_path(@parent))
  end

  def update
    @item = Sys::User.find(params[:id])
    @item.attributes = group_user_params
    old_password = @item.password_was

    _update(@item, location: sys_groups_path(@parent)) do
      if Core.user.id == @item.id && @item.password != old_password
        new_login @item.account, @item.password
      end
    end
  end

  def destroy
    @item = Sys::User.find(params[:id])
    _destroy(@item, location: sys_groups_path(@parent))
  end

  private

  def group_user_params
    params.require(:item).permit(
      :account, :name, :name_en, :email, :state, :auth_no, :ldap, :password,
      :in_group_id, :in_role_name_ids
    )
  end
end
