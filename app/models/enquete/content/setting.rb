# encoding: utf-8
class Enquete::Content::Setting < Cms::ContentSetting
  set_config :from_email, name: "差出人メールアドレス"
  set_config :email, name: "通知先メールアドレス"
  set_config :auto_reply, name: "自動返信",
                          options: [%w(返信する send), %w(返信しない none)]
  set_config :upper_reply_text, name: "自動返信テキスト（上部）",
                                form_type: :text
  set_config :lower_reply_text, name: "自動返信テキスト（下部）",
                                form_type: :text
  set_config :use_captcha, name: "画像認証",
                           options: [["使用する", 1], ["使用しない", 0]]
  set_config :required_symbol, :name => "必須記号", :lower_text => '非表示の場合は、「_blank」と入力する'
  set_config :auto_add_attr_title, :name => "属性の自動付加（title属性）",
    :options => [["付加する", 1], ["付加しない", 0]]
end
