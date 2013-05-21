# encoding: utf-8
class Sys::Admin::ProcessesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Cms::Controller::Scaffold::Process
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    
    if params[:id]
      @process_name = params[:id].to_s.gsub(/^(.*)@/, '\\1#').gsub(/@/, '/')
      return http_error(500) if @process_name =~ /[^\w_#\/]/
    end
  end
  
  def processes
    [
      ["日時指定処理"      , "sys/tasks#exec"],
      ["ページ書き出し"    , "cms/nodes#publish"],
      ["音声書き出し"      , "cms/talks#publish"],
      ["フィード取り込み"  , "cms/feeds#read"],
      ["メルマガ読者登録"  , "newsletter/requests#read"],
      ["記事再構築"        , "article/docs#rebuild"],
      ["FAQ再構築"         , "faq/docs#rebuild"],
      ["アンケート取り込み", "enquete/answers#pull"],
    ]
  end
  
  def index
    @items = []
    processes.each do |title, name|
      item = Sys::Process.find_by_name(name) || Sys::Process.new
      item.title  = title
      item.name ||= name
      @items << item
    end
  end
  
  def show
    #res = ::Script.run(@process_name); raise "process: #{@process_name}"
    
    @process = Sys::Process.find_by_name(@process_name) || Sys::Process.new(:name => @process_name)
    processes.each {|title, name| @process.title = title if name == @process_name }
    
    return send(params[:do]) if params[:do] =~ /^(start|stop)_process/
  end
  
protected

end
