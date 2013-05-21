# encoding: utf-8
class Sys::Script::RunnerController < ApplicationController
  
  def run
    Dir.chdir("#{Rails.root}")
    
    render_component :params => params,
      :controller => ::File.dirname(params[:path]),
      :action     => ::File.basename(params[:path])
    
    #return render(:text => "OK")
    
  rescue Script::InterruptException => e
    Script.log "Interrupt: #{e}"
  rescue LoadError => e
    Script.error "#{e}"
  rescue Exception => e
    Script.error "#{e}"
  end
end
