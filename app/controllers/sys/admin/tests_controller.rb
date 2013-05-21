# encoding: utf-8
class Sys::Admin::TestsController < Cms::Controller::Admin::Base
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    redirect_to sys_tests_mail_path
  end
end
