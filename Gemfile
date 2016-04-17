source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'rack', '1.6.4'
gem 'rake', '11.1.0'
gem 'mysql2','0.4.3'
gem 'rmagick', '2.13.4'
gem 'hpricot', '0.8.6'
gem 'tamtam', '0.0.3'
#gem 'jpmobile', '~> 4.2.0'
gem 'jpmobile', :git => 'https://github.com/jpmobile/jpmobile.git',
                :branch => 'rails-4-2'
gem 'will_paginate', '3.0.7'
gem 'dynamic_form', '1.1.4'
gem 'mail-iso-2022-jp', '2.0.2'
gem 'mime-types', '1.22'
gem 'rails_autolink', '~> 1.1.6'
gem 'jquery-rails', '~> 2.2.1'
gem 'therubyracer', '0.11.4', :platforms => :ruby
gem 'simple_captcha2', '~> 0.3.4', :require => 'simple_captcha'
gem 'multi_db', '0.3.1'
gem 'nokogiri', '~> 1.6.7.2'
gem 'parallel', '~> 1.6.1'
gem 'sass-rails',   '~> 5.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'uglifier', '>= 1.3.0'
gem 'whenever', require: false

require "yaml"
gem 'ruby-ldap', '0.9.12' if ::YAML.load_file(File.dirname(__FILE__) + "/config/application.yml")["sys"]["use_ldap"]

group :development do
  gem 'rubocop', require: false
end
