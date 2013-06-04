# encoding: utf-8
namespace :db do
  
  namespace :seed do
    
    ## sample data
    task :demo => :environment do
      load "#{Rails.root}/db/seed/demo.rb"
      exit
    end
    
    ## test data
    task :test => :environment do
      load "#{Rails.root}/db/seed/test.rb"
      exit
    end
  end
  
  namespace :session do
    ## sweep session
    task :sweep => :environment do
      Session.sweep
      exit
    end
  end
  
  namespace :storage do
    
    ## import file to db
    task :load => :environment do
      load "#{Rails.root}/db/storage/load.rb"
      exit
    end
  end
end