# encoding: utf-8
class Cms::Admin::Tool::LinkChecksController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Cms::Controller::Scaffold::Process
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
  end
  
  def index
    @process_name = "cms/link_checks#check"
    return send(params[:do]) if params[:do] =~ /^(start|stop)_process/
    
    @log = Cms::LinkCheck.find(:first)
    return send(params[:do]) if params[:do] =~ /^logs$/
  end
  
protected

  def start_process
    options = { :site_id => Core.site.id }
    options[:external] = true if params[:external]
    
    #::Script.run(@process_name, options); exit
    
    super(@process_name, options)
  end
  
  def logs
    require 'nkf'
    require 'csv'
    
    csv = CSV.generate do |csv|
      csv << ["ログID", "チェック日時", "リンク先URL", "結果", "リンク元URL", "リンク元数"]
      
      @logs = Cms::LinkCheck.find(:all)
      @logs.each do |data|
        row = []
        row << data.id
        row << data.created_at.to_s(:db)
        row << data.link_uri
        row << data.state
        row << data.source_uri
        row << data.source_count
        csv << row
      end
    end
    
    csv = NKF.nkf('-s', csv)
    send_data(csv, :type => 'text/csv', :filename => "link_check_logs_#{Time.now.to_i}.csv")
  end
end
