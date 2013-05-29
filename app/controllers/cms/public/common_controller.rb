# encoding: utf-8
class Cms::Public::CommonController < ApplicationController
  
  def index
    @skip_layout = true
    
    return http_error(404) if !Page.site
    
    path = "#{Rails.root}/public#{Core.request_uri}"
    return http_error(404) if !::Storage.exists?(path)
    
    send_storage_file path
  end
end