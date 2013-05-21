# encoding: utf-8
class Newsletter::Admin::RequestsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item = Newsletter::Request.new
    return export_csv if params[:do] == "csv"
    
    item = Newsletter::Request.new
    item.and :content_id, @content.id
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'created_at DESC'
    @items = item.find(:all)
    _index @items
  end
  
protected
  
  def export_csv
    require 'nkf'
    require 'csv'
    
    item = Newsletter::Request.new
    item.and :content_id, @content.id
    items = item.find(:all, :order => :created_at)
    
    csv = CSV.generate do |csv|
      csv << ["送信日時", "IPアドレス", "メールアドレス", "メール種別", "要求", "状態"]
      items.each do |item|
        row = []
        row << item.created_at.to_s(:db)
        row << item.ipaddr
        row << item.email
        row << item.letter_type_name
        row << item.request_type_name
        row << (item.state == "disabled" ? "完了" : "待機")
        csv << row
      end
    end
    
    csv = NKF.nkf('-s', csv)
    send_data csv, :type => 'text/csv', :filename => "#{::File.basename(params[:controller])}_#{Time.now.to_i}.csv"
  end
end
