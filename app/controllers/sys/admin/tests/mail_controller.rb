# encoding: utf-8
class Sys::Admin::Tests::MailController < Cms::Controller::Admin::Base
  
  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:manager)
  end
  
  def index
    @config = {}
    ApplicationMailer.smtp_settings.each do |key, value|
      @config[key] = value
      @config[key] = "****" if key.to_s == "user_name" && !value.blank?
      @config[key] = "****" if key.to_s == "password" && !value.blank?
    end
    
    @errors = []
    
    @item = params[:item] || {}
    @item[:from]    ||= "#{Core.user.email}"
    @item[:to]      ||= "#{Core.user.email}"
    @item[:subject] ||= "テストメール"
    @item[:body]    ||= "メール送信の動作確認を行っています。"
    
    if request.post? && params[:commit_send]
      @errors << "差出人を入力してください。" if @item[:from].blank?
      @errors << "宛先を入力してください。" if @item[:to].blank?
      @errors << "件名を入力してください。" if @item[:subject].blank?
      
      if @errors.size == 0
        begin
          send_mail(@item)
        rescue => e
          @errors << "送信に失敗しました。"
          @errors << e.to_s
        else
          flash[:notice] = "メールを送信しました。"
          redirect_to url_for(:sent => 1)
        end
      end
    end
  end
end
