# encoding: utf-8
class Newsletter::Request < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept
  include Newsletter::Model::Base::Letter

  belongs_to :status,      :foreign_key => :state,        :class_name => 'Sys::Base::Status'
  belongs_to :content,     :foreign_key => :content_id,   :class_name => 'Newsletter::Content::Base'

  validates_presence_of :state, :request_type, :email
  validates_presence_of :letter_type,
    :if => %Q(request_type == "subscribe")
  
  validate :validate_email
  
  apply_simple_captcha :message => "の画像と文字が一致しません。"
  
  def statuses
    [['待機','enabled'], ['完了','disabled']]
  end
  
  def request_types
    [["登録","subscribe"],["解除","unsubscribe"]]
  end
  
  def request_type_name
    request_types.each {|v,k| return v if k == request_type }
    return request_type
  end
  
  def letter_types
    [["PC版(テキスト形式)","pc_text"],["携帯版(テキスト形式)","mobile_text"]]
  end
  
  def validate_email
    if !email.blank?
      if email !~ /@((\w+-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/ix
        errors.add :email, :invalid
      elsif email =~ /^((\..*?)|(.*?\.\..*?)|(.*?\.))@/ix
        errors.add :email, :invalid
      elsif email !~ /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@/ix
        errors.add :email, :invalid
      end
    end
  end
  
  def email_hash
    require 'digest/md5'
    Digest::MD5.new.update("#{email}#{Joruri.config[:sys_crypt_pass]}").to_s
  end
  
  def subscribe_guide_body
    line = '-' * (mobile? ? 15 : 50)
    
    body = []
    body << "下記のURLにアクセスして登録を完了させてください。\n"
    body << "#{content.form_node.public_full_uri}subscribe/#{CGI.escape(email)}/#{email_hash}?type=#{letter_type}\n\n"
    body << "#{line}\n"
    body << "■メールアドレス\n#{email}\n\n"
    body << "■メールタイプ\n#{letter_type_name}\n"
    body << "#{line}\n"
    body << "#{mobile? ? content.signature_mobile : content.signature}\n" if content.signature_state == 'enabled'
    body.join
  end
  
  def unsubscribe_guide_body
    line = '-' * (mobile? ? 15 : 50)
    
    body = []
    body << "下記のURLにアクセスして解除を完了させてください。\n"
    body << "#{content.form_node.public_full_uri}unsubscribe/#{CGI.escape(email)}/#{email_hash}\n\n"
    body << "#{line}\n"
    body << "■メールアドレス\n#{email}\n"
    body << "#{line}\n"
    body << "#{mobile? ? content.signature_mobile : content.signature}\n" if content.signature_state == 'enabled'
    body.join
  end
  
  def subscribe_notice_body
    line = '-' * (mobile? ? 15 : 50)
    
    body = []
    body << "#{content.name}にご登録いただきありがとうございます。\n\n"
    body << "下記の内容で登録いたしました。\n"
    body << "#{line}\n"
    body << "■メールアドレス\n#{email}\n\n"
    body << "■メールタイプ\n#{letter_type_name}\n"
    body << "#{line}\n"
    body << "次回より、#{content.name}を配信いたします。\n\n"
    body << "※登録を希望した覚えがない方は、大変お手数ですが下記のページから解除手続きを行ってください。\n"
    body << "#{content.form_node.public_full_uri}change.html\n\n"
    body << "#{mobile? ? content.signature_mobile : content.signature}\n" if content.signature_state == 'enabled'
    body.join
  end

  def unsubscribe_notice_body
    body = []
    body << "#{content.name}の解除が完了いたしました。\n\n"
    body << "これまでのご利用ありがとうございました。\n\n"
    body << "#{mobile? ? content.signature_mobile : content.signature}\n" if content.signature_state == 'enabled'
    body.join
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and "#{self.class.table_name}.id", v
      when 's_email'
        self.and_keywords v, :email
      when 's_letter_type'
        self.and "#{self.class.table_name}.letter_type", v
      when 's_request_type'
        self.and "#{self.class.table_name}.request_type", v
      when 's_state'
        self.and "#{self.class.table_name}.state", v
      when 's_keyword'
        self.and_keywords v, :email
      end
    end if params.size != 0

    return self
  end
end