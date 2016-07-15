# encoding: utf-8
namespace :sys do |_n|
  namespace :tasks do
    task exec: :environment do
      Script.run('sys/tasks#exec')
    end
  end
end
