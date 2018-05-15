# encoding: utf-8
require 'nkf'
require 'csv'
class Enquete::Admin::FormAnswersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Recognition
  include Sys::Controller::Scaffold::Publication
  helper Article::FormHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)

    @content = Cms::Content.find(params[:content])
    return error_auth unless @content
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)

    @form = Enquete::Form.find(params[:form])
    return error_auth unless @form

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    return download_csv if params[:output] == 'csv'

    @items = Enquete::Answer
             .where(content_id: @content.id)
             .where(form_id: @form.id)
             .order(id: :desc)
             .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def download_csv
    @items = Enquete::Answer
             .where(content_id: @content.id)
             .where(form_id: @form.id)
             .order(id: :desc)

    columns = @form.public_columns.collect { |col| [col.id, col.name] }

    csv = CSV.generate do |csv|
      row = []
      row << 'No'
      row << 'ID'
      row << "回答日時"
      row << "IPアドレス"

      row += columns.collect { |_k, v| v }
      csv << row

      @items.each_with_index do |item, idx|
        row = []
        row << @items.size - idx
        row << item.id
        row << (begin
                  item.created_at.strftime('%Y-%m-%d %H:%M')
                rescue
                  nil
                end)
        row << item.ipaddr

        columns.each { |id, _name| row << item.column_value(id) }
        csv << row
      end
    end

    filename = "#{@form.name}_#{Time.now.strftime('%Y-%m-%d')}"
    filename = CGI.escape(filename) if request.env['HTTP_USER_AGENT'] =~ /MSIE/
    csv = NKF.nkf('-sW -Lw', csv)
    send_data(csv, type: 'text/csv; charset=Shift_JIS', filename: "#{filename}.csv")
  end

  def show
    @item = Enquete::Answer.find(params[:id])

    _show @item
  end

  def new
    @item = Enquete::Answer.new(state: 'public')
  end

  def edit
    error_auth
  end

  def create
    @item = Enquete::Answer.new(params[:item])
    @item.content_id = @content.id

    _create @item
  end

  def update
  end

  def destroy
    @item = Enquete::Answer.find(params[:id])
    _destroy @item
  end

  protected
end
