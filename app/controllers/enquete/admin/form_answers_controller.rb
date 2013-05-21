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
    return error_auth unless @content = Cms::Content.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return error_auth unless @form = Enquete::Form.find(params[:form])
    #default_url_options :content => @content.id, :form => @form.id
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    return download_csv if params[:output] == 'csv'
    
    item = Enquete::Answer.new#.public#.readable
    #item.public unless Core.user.has_auth?(:manager)
    item.and :content_id, @content.id
    item.and :form_id, @form.id
    #item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'id DESC'
    @items = item.find(:all)
    _index @items
  end
  
  def download_csv
    item = Enquete::Answer.new#.public#.readable
    item.and :content_id, @content.id
    item.and :form_id, @form.id
    item.order params[:sort], 'id DESC'
    @items = item.find(:all)
    
    columns = @form.public_columns.collect{|col| [col.id, col.name]}
    
    csv = CSV.generate do |csv|
      row = []
      row << "No"
      row << "ID"
      row << "回答日時"
      row << "IPアドレス"
      #row << "ユーザエージェント"
      row += columns.collect {|k,v| v }
      csv << row
      
      @items.each_with_index do |item, idx|
        row = []
        row << @items.size - idx
        row << item.id
        row << (item.created_at.strftime('%Y-%m-%d %H:%M') rescue nil)
        row << item.ipaddr
        #row << item.user_agent
        columns.each {|id, name| row << item.column_value(id) }
        csv << row
      end
    end
    
    filename = "#{@form.name}_#{Time.now.strftime('%Y-%m-%d')}"
    filename = CGI::escape(filename) if request.env['HTTP_USER_AGENT'] =~ /MSIE/
    csv = NKF.nkf('-sW -Lw', csv)
    send_data(csv, :type => 'text/csv; charset=Shift_JIS', :filename => "#{filename}.csv")
  end
  
  def show
    @item = Enquete::Answer.new.find(params[:id])
    #return error_auth unless @item.readable?
    
    _show @item
  end

  def new
    @item = Enquete::Answer.new({
      :state        => 'public'
    })
  end

  def edit
    return error_auth
  end

  def create
    @item = Enquete::Answer.new(params[:item])
    @item.content_id = @content.id

    _create @item
  end

  def update
#    @item = Enquete::Answer.new.find(params[:id])
#    @item.attributes = params[:item]
#
#    _update(@item)
  end

  def destroy
    @item = Enquete::Answer.new.find(params[:id])
    _destroy @item
  end

protected
end
