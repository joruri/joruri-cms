# encoding: utf-8
class Enquete::Content::Setting < Cms::ContentSetting
  set_config :from_email, :name => "差出人メールアドレス"
  set_config :email, :name => "通知先メールアドレス"
  set_config :auto_reply, :name => "自動返信",
    :options => [['返信する','send'],['返信しない','none']]
  set_config :upper_reply_text, :name => "自動返信テキスト（上部）",
    :form_type => :text
  set_config :lower_reply_text, :name => "自動返信テキスト（下部）",
    :form_type => :text
  set_config :use_captcha, :name => "画像認証",
    :options => [["使用する", 1], ["使用しない", 0]]
end