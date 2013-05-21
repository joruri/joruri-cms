# encoding: utf-8
class Sys::Admin::RebootController < Cms::Controller::Admin::Base
  def index
    f = ::File.open(::File.join(Rails.root.to_s, 'tmp/restart.txt'), 'w')
    f.close
    
    skip_layout
    render :action => 'index'
  end
end
