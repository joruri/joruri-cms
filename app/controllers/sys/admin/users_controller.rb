# encoding: utf-8
class Sys::Admin::UsersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item = Sys::User.new # for search
    @item.in_group_id = params[:s_group_id]

    @items = Sys::User.search(params)
                      .order("LPAD(account, 15, '0')")
                      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Sys::User.find(params[:id])
    return error_auth unless @item.readable?

    _show @item
  end

  def new
    @item = Sys::User.new(state: 'enabled',
                          ldap: '0',
                          auth_no: 2)
  end

  def create
    @item = Sys::User.new(user_params)
    _create(@item)
  end

  def update
    @item = Sys::User.find(params[:id])
    @item.attributes = user_params
    old_password = @item.password_was

    _update(@item) do
      if Core.user.id == @item.id && @item.password != old_password
        new_login @item.account, @item.password
      end
    end
  end

  def destroy
    @item = Sys::User.find(params[:id])
    _destroy(@item)
  end

  private

  def user_params
    params.require(:item).permit(
      :in_group_id, :account, :name, :name_en, :email, :state, :auth_no,
      :in_role_name_ids, :ldap, :password)
  end
end
