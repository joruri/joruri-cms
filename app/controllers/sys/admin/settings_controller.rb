# encoding: utf-8
class Sys::Admin::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = Sys::Setting.configs
    _index @items
  end

  def show
    @item = Sys::Setting.config(params[:id])
    _show @item
  end

  def new
    error_auth
  end

  def create
    error_auth
  end

  def update
    @item = Sys::Setting.config(params[:id])
    @item.value = params[:item][:value]
    _update(@item)
  end

  def destroy
    error_auth
  end
end
