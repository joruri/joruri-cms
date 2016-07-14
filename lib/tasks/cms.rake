# encoding: utf-8
namespace :cms do
  namespace :nodes do
    task publish: :environment do
      Script.run('cms/nodes#publish')
    end
  end

  namespace :nodes do
    task publish_all: :environment do
      Script.run('cms/nodes#publish?all=all')
    end
  end

  namespace :nodes do
    task publish_top: :environment do
      Script.run('cms/nodes#publish_top')
    end
  end

  namespace :nodes do
    task publish_category: :environment do
      Script.run('cms/nodes#publish_category')
    end
  end

  namespace :nodes do
    task publish_attribute: :environment do
      Script.run('cms/nodes#publish_attribute')
    end
  end

  namespace :nodes do
    task publish_area: :environment do
      Script.run('cms/nodes#publish_area')
    end
  end

  namespace :nodes do
    task publish_unit: :environment do
      Script.run('cms/nodes#publish_unit')
    end
  end

  namespace :talks do
    task publish: :environment do
      Script.run('cms/talks#publish')
    end
  end

  namespace :feeds do
    task read: :environment do
      Script.run('cms/feeds#read')
    end
  end
end
