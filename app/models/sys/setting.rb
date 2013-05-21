# encoding: utf-8
class Sys::Setting < Sys::Model::Base::Setting
  
  validates_presence_of :name
  
  set_config :change_user_name, :name => "ログインユーザによるユーザ情報の変更",
    :options => [['許可','allowed'],['拒否（標準）','denied']],
    :default => :denied
  set_config :change_user_password, :name => "ログインユーザによるパスワードの変更",
    :options => [['許可','allowed'],['拒否（標準）','denied']],
    :default => :denied
  
end
