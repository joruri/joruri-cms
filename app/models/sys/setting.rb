# encoding: utf-8
class Sys::Setting < Sys::Model::Base::Setting
  validates :name, presence: true

  set_config :change_user_name,
             name: "ログインユーザーによるユーザー情報の変更",
             options: [%w(許可 allowed), ['拒否（標準）', 'denied']],
             default: :denied

  set_config :change_user_password,
             name: "ログインユーザーによるパスワードの変更",
             options: [%w(許可 allowed), ['拒否（標準）', 'denied']],
             default: :denied

  set_config :lockout_allow_attempt_count, 
             name: "ユーザのロックアウト閾値（ログイン失敗回数）",
             options: [['1','1'],['2','2'],['3','3'],['4','4'],['5','5'],['6','6'],['7','7'],['8','8'],['9','9'],['10','10'],
          ['11','11'],['12','12'],['13','13'],['14','14'],['15','15']]

  set_config :display_parent_group_name,
             name: "連絡先の上位所属名を全て表示",
             options: [%w(有効 enabled), ['無効（標準）', 'disabled']],
             default: :disabled

end
