# encoding: utf-8
namespace :faq do
  
  namespace :docs do
    task :rebuild => :environment do
      Script.run('faq/docs#rebuild')
    end
  end
end