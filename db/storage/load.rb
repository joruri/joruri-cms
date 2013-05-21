# encoding: utf-8

## valid
if Storage.env != :db
  puts "storage type is not 'db' (application.yml)"
  exit
end

## truncate
puts "truncate table storage_files"
ActiveRecord::Base.connection.execute "TRUNCATE TABLE storage_files"

## import
dirs = ["#{Rails.root}/public", "#{Rails.root}/public_00000001"]

dirs.each do |dir|
  puts "import #{dir}"
  ::Storage.import(dir)
end
