# encoding: utf-8
class Article::Admin::Tool::ImportUriController < Cms::Controller::Admin::Base
  require "nkf"
  
  def import
    uri = params[:uri]#.join('/')
    return http_error(404) if uri.blank?
    
    res = Util::Http::Request.get(uri)
    return http_error(404) if res.status != 200
    
    data = res.body.to_utf8.gsub(/.*<body[^>]+>(.*)<\/body>.*/m, '\\1')
    
    render :text => data
  rescue => e
    return http_error(404)
  end
end
