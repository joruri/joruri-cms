# encoding: utf-8
class Newsletter::Content::Setting < Cms::ContentSetting
  set_config :sender_address,     :name => "送信元メールアドレス"
  set_config :use_captcha,        :name => "画像認証", :options => [["使用する", 1], ["使用しない", 0]]
  set_config :summary,            :name => "概要"
  set_config :addition_body,      :name => "説明（登録フォーム）"
  set_config :deletion_body,      :name => "説明（解除フォーム）"
  set_config :sent_addition_body, :name => "送信後のメッセージ（登録完了）"
  set_config :sent_deletion_body, :name => "送信後のメッセージ（解除案内）"
  set_config :template_state,     :name => "テンプレート：使用", :options => [['有効','enabled'], ['無効','disabled']]
  set_config :template,           :name => "テンプレート：PC版"
  set_config :template_mobile,    :name => "テンプレート：携帯版"
  set_config :signature_state,    :name => "署名：表示", :options => [['有効','enabled'], ['無効','disabled']]
  set_config :signature,          :name => "署名：PC版メールフッタ"
  set_config :signature_mobile,   :name => "署名：携帯版メールフッタ"

  def config_view_set
    case name
    when 'summary', 'addition_body', 'deletion_body', 'sent_addition_body', 'sent_deletion_body'
      return {:form => "text_area", :style => "height: 200px;", :class => 'body mceEditor', :show_class => 'mceEditor' }
    when 'signature_state', 'template_state'
      return {:form => "radio_buttons", :options => config_options, :class => 'state' }
    when 'signature', 'signature_mobile'
      return {:form => "text_area", :style => "width: 600px; height: 200px;", :class => 'autoWrap mailBodyText' }
    when 'template', 'template_mobile'
      return {:form => "text_area", :style => "width: 600px; height: 300px;", :class => 'autoWrap mailBodyText' }
    end
    nil
  end
end
