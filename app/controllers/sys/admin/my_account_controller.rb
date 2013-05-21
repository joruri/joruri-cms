# encoding: utf-8
class Sys::Admin::MyAccountController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  
  def index
    @item = Core.user
  end
  
  def show
    @item = Core.user
  end
  
  def edit
    return error_auth if Sys::Setting.value(:change_user_name) != "allowed"
    
    @item = Core.user
  end
  
  def edit_password
    return error_auth if Sys::Setting.value(:change_user_password) != "allowed"
    
    @item = Sys::User.new
  end
  
  def update
    return update_password if params[:item][:password]
    return error_auth if Sys::Setting.value(:change_user_name) != "allowed"
    
    attrs = [:name, :name_en, :email]
    
    @item = Core.user
    attrs.each {|name| @item.send("#{name}=", params[:item][name]) }
    
    def @item.editable?
      true
    end
    
    _update(@item, :location => url_for(:action => :show))
  end
  
  def update_password
    return error_auth if Sys::Setting.value(:change_user_password) != "allowed"
    
    @item = Sys::User.new
    @item.current_password = params[:item][:current_password]
    
    if params[:item][:current_password].blank?
      @item.errors.add :current_password, :empty
    elsif params[:item][:current_password] != Core.user.password
      @item.errors.add :current_password, :invalid
    elsif params[:item][:new_password].blank?
      @item.errors.add :new_password, :blank
    elsif params[:item][:new_password] != params[:item][:confirm_password]
      @item.errors.add :new_password, "が#{@item.locale(:confirm_password)}と一致しません。"
    end
    
    if @item.errors.size > 0
      return render(:action => :edit_password)
    end
    
    @item = Core.user
    @item.password = params[:item][:new_password]
    
    def @item.editable?
      true
    end
    
    _update(@item, :location => url_for(:action => :show)) do
      new_login @item.account, @item.password
    end
  end
end
