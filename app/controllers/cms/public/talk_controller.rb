# encoding: utf-8
class Cms::Public::TalkController < Cms::Controller::Public::Base
  
  def index
    @skip_layout = true
    
    path = ::File.join(Page.site.public_path, Core.request_uri)
    path = path.gsub(/\.html\.r\.mp3$/, '.html.mp3')
    path = ::File.join("#{Page.site.public_path}404.html.mp3") if !::Storage.exists?(path)
    path = ::File.join("#{Rails.root}/public/404.html.mp3") if !::Storage.exists?(path)
    return http_error(404) if !::Storage.exists?(path)
    
    send_storage_file path
  end
end
