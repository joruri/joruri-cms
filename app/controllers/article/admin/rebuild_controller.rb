# encoding: utf-8
class Article::Admin::RebuildController < Cms::Controller::Admin::Base
  include Cms::Controller::Scaffold::Process
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
  end
  
  def index
    @process_name = "article/docs#rebuild"
    return send(params[:do]) if params[:do] =~ /^(start|stop)_process/
  end
  
protected

  def start_process
    options = { :content_id => @content.id }
    options[:file] = true if params[:file]
    
    super(@process_name, options)
  end
end
