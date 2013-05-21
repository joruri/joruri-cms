# encoding: utf-8
class Cms::Script::FeedsController < ApplicationController
  include Cms::Controller::Layout

  def read
    feeds = Cms::Feed.find(:all, :conditions => { :state => 'public' })
    
    Script.total feeds.size
    
    feeds.each do |feed|
      Script.current
      
      begin
        if feed.update_feed
          Script.success
        else
          raise feed.uri
        end
      rescue Script::InterruptException => e
        raise e
      rescue => e
        Script.error e
      end
    end

    render :text => "OK"
  end
end
