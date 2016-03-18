source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'rack', '1.4.5'
gem 'rake', '10.0.4'
gem 'mysql2','0.3.11'
gem 'rmagick', '2.13.1'
gem 'hpricot', '0.8.6'
gem 'tamtam', '0.0.3'
gem 'jpmobile', '3.0.1'
gem 'will_paginate', '3.0.3'
gem 'render_component_vho', '3.2.1'
gem 'dynamic_form', '1.1.4'
gem 'mail-iso-2022-jp', '2.0.2'
gem 'mime-types', '1.22'
gem 'rails_autolink', '1.0.9'
gem 'jquery-rails', '2.2.1'
gem 'therubyracer', '0.11.4', :platforms => :ruby
gem 'galetahub-simple_captcha', '0.1.5', :require => 'simple_captcha'
gem 'multi_db', '0.3.1'
gem 'thin','1.5.1'
gem 'nokogiri', '~> 1.5.9'
gem 'parallel', '~> 1.6.1'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

require "yaml"
gem 'ruby-ldap', '0.9.12' if ::YAML.load_file(File.dirname(__FILE__) + "/config/application.yml")["sys"]["use_ldap"]
