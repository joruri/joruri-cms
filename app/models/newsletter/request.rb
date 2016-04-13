# encoding: utf-8
class Newsletter::Request < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Cms::Model::Rel::Concept
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Concept
  include Newsletter::Model::Base::Letter

  include StateText

  belongs_to :content, foreign_key: :content_id,
                       class_name: 'Newsletter::Content::Base'

  validates :state, :request_type, :email, presence: true
  validates :letter_type, presence: true, if: %(request_type == "subscribe")

  validate :validate_email

  apply_simple_captcha message: "の画像と文字が一致しません。"

  scope :search, ->(params) {
    rel = all

    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        rel = rel.where(arel_table[:id].eq(v))
      when 's_email'
        rel = rel.where(arel_table[:email].matches("%#{v}%"))
      when 's_letter_type'
        rel = rel.where(arel_table[:letter_type].eq(v))
      when 's_request_type'
        rel = rel.where(arel_table[:request_type].eq(v))
      when 's_state'
        rel = rel.where(arel_table[:state].eq(v))
      when 's_keyword'
        rel = rel.where(arel_table[:email].matches("%#{v}%"))
      end
    end if params.size != 0

    rel
  }

  def statuses
    [%w(待機 enabled), %w(完了 disabled)]
  end

  def request_types
    [%w(登録 subscribe), %w(解除 unsubscribe)]
  end

  def request_type_name
    request_types.each { |v, k| return v if k == request_type }
    request_type
  end

  def letter_types
    [["PC版(テキスト形式)", 'pc_text'], ["携帯版(テキスト形式)", 'mobile_text']]
  end

  def validate_email
    unless email.blank?
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
end
