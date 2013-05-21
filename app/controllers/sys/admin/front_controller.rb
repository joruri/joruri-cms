# encoding: utf-8
class Sys::Admin::FrontController < Cms::Controller::Admin::Base
  def index
    item = Sys::Message.new.public
    @messages = item.find(:all, :order => 'published_at DESC')
    
    item = Sys::Maintenance.new.public
    @maintenances = item.find(:all, :order => 'published_at DESC')
    
    #@calendar = Util::Date::Calendar.new(nil, nil)
  end
end
