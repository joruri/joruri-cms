# encoding: utf-8
class Bbs::Content::Setting < Cms::ContentSetting
  set_config :admin_password, :name => "管理者パスワード",
    :lower_text => "すべての投稿を削除できるパスワードです。"
  set_config :link_entry_form, :name => "投稿フォームの表示",
    :options => [["一覧に表示する", 0], ["リンクで表示する", 1]]
  set_config :show_email, :name => "Emailの表示",
    :options => [["表示する", 1], ["表示しない", 0]]
  set_config :show_uri, :name => "URLの表示",
    :options => [["表示する", 1], ["表示しない", 0]]
  set_config :use_captcha, :name => "画像認証",
    :options => [["使用する", 1], ["使用しない", 0]]
  set_config :use_password, :name => "パスワードによる削除機能",
    :options => [["使用する", 1], ["使用しない", 0]]
  set_config :use_once_click, :name => "２重送信防止機能",
    :options => [["使用する", 1], ["使用しない", 0]]
  set_config :block_uri, :name => "URL投稿の拒否",
    :options => [["許可する", 0],["拒否する", 1]]
  set_config :block_word, :name => "禁止語句の設定", :form_type => :text,
    :lower_text => "スペースまたは改行で複数指定できます。"
  set_config :block_ipaddr, :name => "拒否IPアドレスの設定", :form_type => :text,
    :lower_text => "スペースまたは改行で複数指定できます。\n「*」はワイルドカードとして使用できます。"
end