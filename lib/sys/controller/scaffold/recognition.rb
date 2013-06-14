# encoding: utf-8
module Sys::Controller::Scaffold::Recognition
  def recognize(item)
    _recognize(item)
  end
  
protected
  def _recognize(item, options = {}, &block)
    if item.recognizable?(Core.user) && item.recognize(Core.user)
      location       = options[:location] || url_for(:action => :index)
      flash[:notice] = options[:notice] || '承認処理が完了しました。'
      Sys::OperationLog.log(request, :item => item)
      yield if block_given?
      
      respond_to do |format|
        format.html { redirect_to(location) }
        format.xml  { head :ok }
      end
    else
      flash[:notice] = "承認処理に失敗しました。"
      respond_to do |format|
        format.html { redirect_to url_for(:action => :show) }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
