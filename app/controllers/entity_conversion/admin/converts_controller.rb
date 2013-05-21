# encoding: utf-8
class EntityConversion::Admin::ConvertsController < EntityConversion::Admin::TestsController
  include Sys::Controller::Scaffold::Base
  
  def pre_dispatch
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_auth?(:manager)
    
    @log = EntityConversion::Log.find(:first, :conditions => {:content_id => @content.id, :env => :production})

    return redirect_to :action => 'index' if params[:reset]
  end
  
protected
  
  def test
    conv = EntityConversion::Lib::Convertor.factory(:production, :content => @content)
    conv.convert
    redirect_to url_for(:action => :index)
  end
end
