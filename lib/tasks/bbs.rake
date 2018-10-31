# encoding: utf-8
namespace :bbs do
  namespace :threads do
    task pull: :environment do
      Script.run('bbs/threads#pull')
    end
  end
end
