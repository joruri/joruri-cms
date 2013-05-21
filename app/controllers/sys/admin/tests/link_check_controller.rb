# encoding: utf-8
class Sys::Admin::Tests::LinkCheckController < Cms::Controller::Admin::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    @checker = Sys::Lib::Form::Checker.new
    
    @errors = []
    
    @item = params[:item] || {}
    
    check_link if request.post?
  end
  
protected
  def check_link
    body = ''
    @item[:body].split(/\r\n|\n|\r/m).each do |uri|
      next if uri.blank?
      body += %Q(<a href="#{uri}">#{uri}</a>\n).html_safe
    end
    @checker.check_link body
  end
end
