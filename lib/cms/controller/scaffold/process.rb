# encoding: utf-8
module Cms::Controller::Scaffold::Process
  def self.included(mod)
    mod.helper Cms::ProcessHelper
  end

  protected

  def start_process(process_name = @process_name, options = {})
    raise 'undefined process_name' if process_name.blank?

    begin
      ::Script.run_from_web(@process_name, options)
      flash[:notice] = "プロセスを開始しました。"
      redirect_to start_process: Time.now.to_i
    rescue StandardError => e
      raise e
#      flash[:notice] = e.to_s
#      redirect_to {}
    end
  end

  def stop_process(process_name = @process_name)
    raise 'undefined process_name' if process_name.blank?

    proc = Sys::Process.find_by(name: process_name)

    if !proc
      flash[:notice] = "プロセスは実行されていません。"
      redirect_to {}
    elsif proc.state != 'running'
      flash[:notice] = "プロセスは実行されていません。"
      redirect_to {}
    else
      proc.interrupt = 'stop'
      proc.save

      flash[:notice] = "プロセスの停止を要求しました。"
      redirect_to stop_process: Time.now.to_i
    end
  end
end
