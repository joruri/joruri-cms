# encoding: utf-8
namespace :newsletter do
  
  namespace :requests do
    task :read => :environment do
      Script.run('newsletter/requests#read')
    end
  end
end