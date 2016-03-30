# encoding: utf-8
class Sys::Controller::Admin::Base < ApplicationController
  include Sys::Controller::Admin::Auth
  helper Sys::FormHelper
  before_action :pre_dispatch
  #  rescue_from ActiveRecord::RecordNotFound, :with => :error_auth

  def initialize_application
    return false unless super

    @@current_user = false
    if authenticate
      return false unless current_user
      crypt_pass         = Joruri.config[:sys_crypt_pass]
      Core.user          = current_user
      Core.user.password = Util::String::Crypt.decrypt(session[PASSWD_KEY], crypt_pass)
      Core.user_group    = current_user.groups[0]
    end

    true
  end

  def pre_dispatch
    ## each processes before dispatch
  end

  def self.simple_layout
    layout 'admin/base'
  end

  def simple_layout
    self.class.layout 'admin/base'
  end

  private

  def authenticate
    return true  if logged_in?
    return false if request.env['REQUEST_URI'] =~ /^#{Regexp.escape(Joruri.admin_uri)}\/login/
    uri  = request.env['REQUEST_URI']
    uri += "?#{request.env['QUERY_STRING']}" unless request.env['QUERY_STRING'].blank?
    cookies[:sys_login_referrer] = uri
    respond_to do |format|
      format.html { redirect_to("#{Joruri.admin_uri}/login") }
      format.xml  { error 'This is a secure page.' }
    end
  end

  def error_auth
    http_error 403, "アクセス権限がありません。"
  end
end
