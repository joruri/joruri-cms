# encoding: utf-8
class Sys::Script::RunnerController < ApplicationController
  def run
    Dir.chdir(Rails.root.to_s)

    return render_component params: params,
                     controller: ::File.dirname(params[:path]),
                     action: ::File.basename(params[:path])

    # return render(:text => "OK")

  rescue Script::InterruptException => e
    Script.log "Interrupt: #{e}"
  rescue LoadError => e
    Script.error e.to_s
  rescue StandardError => e
    Script.error e.to_s
  end
end
