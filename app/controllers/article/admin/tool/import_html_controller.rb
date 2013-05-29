# encoding: utf-8
class Article::Admin::Tool::ImportHtmlController < ApplicationController
  
#  session :cookie_only => false, :only => :import
  protect_from_forgery :except => [:import]
  
  def import
    return http_error(404) if params[:file].blank?
    return http_error(404) if params[:file].size > (1024*1024*10)
    
    data = params[:file].read.to_s.to_utf8.gsub(/.*?<body[^>]+>(.*)<\/body>.*/m, '\\1')
    data = data.gsub(/<script[^>]+>.*?<\/script>/m, '')
    
    render :text => data
  rescue
    return http_error(404)
  end
end
