# encoding: utf-8

namespace :db do
  namespace :storage do
    
    ## import file to db
    task :load => :environment do
      load "#{Rails.root}/db/storage/load.rb"
    end
  end
end