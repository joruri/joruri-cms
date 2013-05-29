# encoding: utf-8
namespace :article do
  
  namespace :docs do
    task :rebuild => :environment do
      Script.run('article/docs#rebuild')
    end
  end
end