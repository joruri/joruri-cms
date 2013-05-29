# encoding: utf-8
namespace :enquete do
  
  namespace :answers do
    task :pull => :environment do
      Script.run('enquete/answers#pull')
    end
  end
end