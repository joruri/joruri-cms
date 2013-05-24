# encoding: utf-8
class Newsletter::Admin::DeliverDocsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Cms::Controller::Scaffold::Process
  helper Newsletter::MailHelper

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Newsletter::Content::Base.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    
    @doc = Newsletter::Doc.find(params[:doc])
    return error_auth unless @doc.editable?
    
    @process_name = "newsletter/docs#deliver"
    @process      = Sys::Process.find_by_name(@process_name)
  end

  def index
    @item = @doc
  end

  def create
    return send(params[:do]) if params[:do].to_s =~ /^deliver_(test|production|log)$/
    return send(params[:do]) if params[:do].to_s =~ /^stop_process$/
    redirect_to url_for(:action => :index)
  end

protected

  def deliver_error(msg)
    flash[:notice] = msg
    redirect_to url_for(:action => :index)
  end
  
  ## テスト配信
  def deliver_test
    success = 0
    
    from = @doc.content.sender_address || @doc.creator.user.email
    @doc.testers.each do |user|
      begin
        send_mail({
          :from    => from,
          :to      => user.email,
          :subject => @doc.mail_title(user.mobile?),
          :body    => @doc.mail_body(user.mobile?)
        })
        success += 1
      rescue Exception => e
        error_log e.to_s
      end
    end
    
    flash[:notice] = "テスト配信が完了しました。 #{success}/#{@doc.testers.size} 件"
    
    respond_to do |format|
      format.html { redirect_to url_for(:action => :index) }
      format.xml  { head :ok }
    end
  end
  
  ## 本配信
  def deliver_production
    if @doc.state != "enabled"
      return deliver_error("記事が無効状態です。")
    elsif @doc.delivery_state != "yet"
      return deliver_error("送信可能な状態ではありません。")
    elsif @process && @process.state == "running"
      return deliver_error("他のコンテンツがメールを配信しています。\nしばらく時間をおいて再度実行してください。")
    end
    
    start_process(@process_name, {:doc_id => @doc.id})
  end
  
  ## 配信ログ
  def deliver_log
    require 'nkf'
    require 'csv'
    
    csv = CSV.generate do |csv|
      csv << ["ログID", "送信日時", "メールアドレス", "メール種別", "結果", "備考"]
      @doc.logs.find(:all, :order => "id").each do |data|
        row = []
        row << data.id
        row << data.created_at.to_s(:db)
        row << data.email
        row << (data.letter_type =~ /pc/ ? "PC" : "携帯")
        row << (data.state == "sent" ? "成功" : data.state).to_s
        row << data.message.to_s
        csv << row
      end
    end
    
    csv = NKF.nkf('-s', csv)
    send_data(csv, :type => 'text/csv', :filename => "newsletter_logs_#{Time.now.to_i}.csv")
  end
end
