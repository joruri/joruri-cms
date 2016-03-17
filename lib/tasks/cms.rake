# encoding: utf-8
namespace :cms do

  namespace :nodes do
    task :publish => :environment do
      Script.run('cms/nodes#publish')
    end

    task :publish_top => :environment do
      Script.run('cms/nodes#publish?target=top')
    end
  end

  namespace :talks do
    task :publish => :environment do
      Script.run('cms/talks#publish')
    end
  end

  namespace :feeds do
    task :read => :environment do
      Script.run('cms/feeds#read')
    end
  end
end
