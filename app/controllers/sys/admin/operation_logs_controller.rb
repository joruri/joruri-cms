# encoding: utf-8
class Sys::Admin::OperationLogsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @item = Sys::OperationLog.new

    @items = Sys::OperationLog.search(params)

    arel_table = Sys::OperationLog.arel_table

    unless params[:start_date].blank?
      @items = @items.where(arel_table[:created_at].gt(params[:start_date]))
    end

    unless params[:close_date].blank?
      date = begin
               Date.strptime(params[:close_date], '%Y-%m-%d') + 1
             rescue
               nil
             end
      @items = @items.where(arel_table[:created_at].lteq(date) if date
    end

    return destroy_items(item.condition.where) if params[:destroy]

    @items = @items.order(params[:sort], id: :desc)

    if params[:csv].blank?
      @items = @items.paginate(page: params[:page], per_page: params[:limit])
    end

    return export_csv(@items) if params[:csv]

    _index @items
  end

  def show
    @item = Sys::OperationLog.find(params[:id])

    _show @item
  end

  def new
    http_error(404)
  end

  def edit
    http_error(404)
  end

  def create
    http_error(404)
  end

  def update
    http_error(404)
  end

  def destroy
    http_error(404)
  end

  protected

  def destroy_items(where)
    num = Sys::OperationLog.delete_all(where)

    flash[:notice] = "削除処理が完了しました。##{num}件"
    redirect_to url_for(action: :index)
  end

  def export_csv(items)
    @item = Sys::OperationLog.new

    require 'nkf'
    require 'csv'

    csv = CSV.generate do |csv|
      fields = ["ログID", :created_at, :user_id, :user_name, :ipaddr, :uri, :action, :item_model, :item_id, :item_unid, :item_name]
      csv << fields.collect { |c| c.is_a?(Symbol) ? @item.locale(c) : c }

      items.each do |item|
        row = []
        row << item.id.to_s
        row << item.created_at.strftime('%Y-%m-%d %H:%M:%S')
        row << item.user_id.to_s
        row << item.user_name.to_s
        row << item.ipaddr.to_s
        row << item.uri.to_s
        row << item.action.to_s
        row << item.item_model.to_s
        row << item.item_id.to_s
        row << item.item_unid.to_s
        row << item.item_name.to_s
        csv << row
      end
    end

    csv = NKF.nkf('-s', csv)
    send_data(csv, type: 'text/csv', filename: "sys_operation_logs_#{Time.now.to_i}.csv")
  end
end
