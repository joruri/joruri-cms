# encoding: utf-8

namespace :db do
  namespace :seed do
    
    ## sample data
    task :demo => :environment do
      load "#{Rails.root}/db/seed/demo.rb"
    end
    
    ## test data
    task :test => :environment do
      load "#{Rails.root}/db/seed/test.rb"
    end
  end
end