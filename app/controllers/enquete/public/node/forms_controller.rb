# encoding: utf-8
class Enquete::Public::Node::FormsController < Cms::Controller::Public::Base
  include Article::Controller::Feed
  include SimpleCaptcha::ControllerHelpers
  
  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    
    @use_captcha = @content.setting_value(:use_captcha) == "1"
  end
  
  def index
    item = Enquete::Form.new.public
    item.and :content_id, @content.id
    #doc.search params
    item.page params[:page], (request.mobile? ? 10 : 20)
    @items = item.find(:all, :order => 'sort_no ASC, id DESC')
  end
  
  def show
    item = Enquete::Form.new.public
    item.and :content_id, @content.id
    item.and :id, params[:form]
    @item = item.find(:first)
    return http_error(404) unless @item
    
    @form = form(@item)
    
    ## post
    @form.submit_values = params[:item]
    return false unless request.post?
    
    ## edit
    return false if params[:edit]
    
    ## validate
    #return false unless @form.valid?
    @form.valid?
    if params[:confirm].blank? && @use_captcha # TODO: change confirm params
      @item.captcha     = params[:item][:captcha]
      @item.captcha_key = params[:item][:captcha_key]
      unless @item.valid_with_captcha?
        @form.errors.add :base, @item.errors.to_a[0]
      end
    end
    return false if @form.errors.size > 0
    
    ## captcha
    # if params[:confirm].blank? && @use_captcha
      # item = Enquete::Form.new
      # item.name        = 'dummy'
      # item.captcha     = params[:item][:captcha]
      # item.captcha_key = params[:item][:captcha_key]
      # unless item.valid_with_captcha?
        # @form.errors.add :base, item.errors.to_a[0]
        # return false
      # end
    # end      
    
    ## confirm
    if params[:confirm].blank?
      @confirm = true
      @form.freeze
      return false
    end
    
    ## save
    client = {
      :ipaddr     => request.remote_addr,
      :user_agent => request.user_agent
    }
    unless answer = @item.save_answer(@form.values(:string), client)
      render :text => "送信に失敗しました。"
      return false
    end
    
    ## send mail to admin
    begin
      send_answer_mail(@item, answer)
    rescue => e
      error_log("メール送信失敗 #{e}")
    end
    
    ## send mail to answer
    answer_email = nil
    answer.columns.each do |col|
      if col.form_column.name =~ /^(メールアドレス|Email|E-mail)/i
        if !col.value.blank?
          answer_email = col.value
          break
        end
      end
    end
    begin
      if @content.setting_value(:auto_reply) == 'send'
        send_answer_mail(@item, answer, answer_email) if !answer_email.blank?
      end
    rescue => e
      error_log("メール送信失敗 #{e}")
    end
    
    redirect_to "#{Page.current_node.public_uri}#{@item.id}/sent.html"
  end
  
  def sent
    item = Enquete::Form.new.public
    item.and :content_id, @content.id
    item.and :id, params[:form]
    @item = item.find(:first)
  end
  
protected
  def form(item)
    form = Sys::Lib::Form::Builder.new(:item, {:template => view_context})
    item.public_columns.each do |col|
      form.add_element(col.column_type, col.element_name, col.name, col.element_options)
    end
    form
  end
  
  def send_answer_mail(item, answer, answer_email = nil)
    mail_fr = @content.setting_value(:from_email)
    if mail_fr.blank?
      mail_fr = "webmaster@" + Page.site.full_uri.gsub(/^.*?\/\/(.*?)(:|\/).*/, '\\1')
      mail_fr = mail_fr.gsub(/www\./, '')
    end
    
    mail_to = answer_email || item.content.setting_value(:email)
    return false if mail_to.blank?
    
    name    = answer_email.blank? ? '投稿' : '自動返信'
    subject = "#{item.name} #{name} | #{item.content.site.name}"
    
    upper_text = item.content.setting_value(:upper_reply_text).to_s
    lower_text = item.content.setting_value(:lower_reply_text).to_s
    
    message = ""
    message += upper_text + "\n" if !upper_text.blank?
    
    message += "■フォーム名\n"
    message += "#{item.name}\n\n"
    message += "■回答日時\n"
    message += "#{answer.created_at.strftime('%Y-%m-%d %H:%M')}\n\n"
    
    if answer_email.blank?
      message += "■IPアドレス\n"
      message += "#{answer.ipaddr}\n\n"
      message += "■ユーザエージェント\n"
      message += "#{answer.user_agent}\n\n"
    end
    
    answer.columns.each do |col|
      message += "■#{col.form_column.name}\n"
      message += "#{col.value}\n\n"
    end
    
    message += lower_text if !lower_text.blank?
    
    send_mail({
      :from    => mail_fr,
      :to      => mail_to,
      :subject => subject,
      :body    => message
    })
  end
end
