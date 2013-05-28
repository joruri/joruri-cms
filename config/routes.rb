Joruri::Application.routes.draw do
  
  ## public
  match "_common/*path"    => "cms/public/common#index"
  match "_layouts/*path"   => "cms/public/layouts#index"
  match "_files/*path"     => "cms/public/files#index", :format => false
  match "_emfiles/*path"   => "cms/public/embedded_files#index", :format => false
  
  ## tools
  match "/_tools/captcha/:action" => "simple_captcha", :as => :simple_captcha
  
  ## admin
  match "#{Joruri.admin_uri}"                 => "sys/admin/front#index"
  match "#{Joruri.admin_uri}/login.:format"   => "sys/admin/account#login"
  match "#{Joruri.admin_uri}/login"           => "sys/admin/account#login"
  match "#{Joruri.admin_uri}/logout.:format"  => "sys/admin/account#logout"
  match "#{Joruri.admin_uri}/logout"          => "sys/admin/account#logout"
  match "#{Joruri.admin_uri}/test"            => "test#index"

  ## modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\./
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end

  ## exception
  match "404.:format"=> "exception#index"
  match "*path"      => "exception#index"
end