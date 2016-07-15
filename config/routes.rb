Joruri::Application.routes.draw do

  ## public
  get "_common/*path"    => "cms/public/common#index"
  get "_layouts/*path"   => "cms/public/layouts#index"
  get "_files/*path"     => "cms/public/files#index", :format => false
  get "_emfiles/*path"   => "cms/public/embedded_files#index", :format => false

  ## tools
  get "/_tools/captcha/:action" => "simple_captcha", :as => :simple_captcha

  ## admin
  get "#{Joruri.admin_uri}"                 => "sys/admin/front#index"
  match "#{Joruri.admin_uri}/login.:format"   => "sys/admin/account#login", via: [:get, :post]
  match "#{Joruri.admin_uri}/login"           => "sys/admin/account#login", via: [:get, :post]
  get "#{Joruri.admin_uri}/logout.:format"  => "sys/admin/account#logout"
  get "#{Joruri.admin_uri}/logout"          => "sys/admin/account#logout"
  get "#{Joruri.admin_uri}/test"            => "test#index"

  ## modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\./
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end

  ## exception
  get "404.:format"=> "exception#index"
  get "*path"      => "exception#index"
end
