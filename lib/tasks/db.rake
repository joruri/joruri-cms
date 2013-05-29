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
  
  namespace :session do
    ## sweep session
    task :sweep => :environment do
      Session.sweep
    end
  end
  
  namespace :storage do
    
    ## import file to db
    task :load => :environment do
      load "#{Rails.root}/db/storage/load.rb"
    end
  end
end