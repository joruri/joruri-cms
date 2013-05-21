# encoding: utf-8
class Sys::Admin::AccountController < Sys::Controller::Admin::Base
  def login
    skip_layout
    admin_uri = "#{Joruri.admin_uri}"
    
    return redirect_to(admin_uri) if logged_in?
    
    @uri = params[:uri] || cookies[:sys_login_referrer] || admin_uri
    @uri = @uri.gsub(/^http:\/\/[^\/]+/, '')
    return unless request.post?
    
    unless new_login(params[:account], params[:password])
      flash.now[:notice] = "ユーザID・パスワードを正しく入力してください。"
      respond_to do |format|
        format.html { render }
        format.xml  { render(:xml => '<errors />') }
      end
      return true
    end
    
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = {
        :value   => self.current_user.remember_token,
        :expires => self.current_user.remember_token_expires_at
      }
    end
    
    cookies.delete :sys_login_referrer
    Sys::OperationLog.log(request, :user => current_user)
    respond_to do |format|
      format.html { redirect_to @uri }
      format.xml  { render(:xml => current_user.to_xml) }
    end
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    
    Sys::OperationLog.log(request, :user => current_user)
    redirect_to('action' => 'login')
  end
end
