# encoding: utf-8
class Sys::Controller::Public::Base < ApplicationController
  include Jpmobile::ViewSelector
  before_filter :pre_dispatch
  
  def pre_dispatch
    ## each processes before dispatch
  end
end
