# encoding: utf-8
class Cms::Public::LayoutsController < Cms::Controller::Public::Base
  
  def index
    @skip_layout = true
    
    return http_error(404) if !Page.site
    
    path = "#{Page.site.public_path}#{Core.request_uri.gsub(/(\d\d)(\d\d)(\d\d)(\d\d)/, '\\1/\\2/\\3/\\4/\\1\\2\\3\\4')}"
    return http_error(404) if !::Storage.exists?(path)
    
    send_storage_file path
  end
end