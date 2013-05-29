# encoding: utf-8
class ApplicationMailer < ActionMailer::Base
  
  Util::Config.load(:smtp).each do |key, val|
    self.smtp_settings[key.to_sym] = val
  end
  
  default :charset => "iso-2022-jp"
  
  def send_mail(params)
    mail(
      :from    => params[:from],
      :to      => params[:to],
      :subject => params[:subject],
      :body    => params[:body],
    )
  end
end