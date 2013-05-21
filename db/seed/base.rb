# encoding: utf-8

## ---------------------------------------------------------
## truncate

def truncate_table(table)
  puts "truncate table #{table}"
  ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table}"
end

Dir::entries("#{Rails.root}/db/seed/base").each do |file|
  next if file !~ /\.rb$/
  load "#{Rails.root}/db/seed/base/#{file}"
end

## ---------------------------------------------------------
## load config

core       = Util::Config.load(:core)
core_uri   = core["uri"]
core_title = core["title"]

## ---------------------------------------------------------
## sys

puts "imported base data."

Sys::Group.create({
  :parent_id => 0,
  :level_no  => 1,
  :sort_no   => 1,
  :state     => 'enabled',
  :web_state => 'closed',
  :ldap      => 0,
  :code      => "root",
  :name      => "組織",
  :name_en   => "soshiki"
})

Sys::User.create({
  :state    => 'enabled',
  :ldap     => 0,
  :auth_no  => 5,
  :name     => "システム管理者",
  :account  => "admin",
  :password => "admin"
})

Sys::UsersGroup.create({
  :user_id  => 1,
  :group_id => 1
})

Core.user       = Sys::User.find_by_account('admin')
Core.user_group = Core.user.groups[0]

## ---------------------------------------------------------
## cms

Sys::Language.create({
  :state   => 'enabled',
  :sort_no => 1,
  :name    => 'japanese',
  :title   => '日本語'
})

site = Cms::Site.create({
  :state    => 'public',
  :name     => core_title,
  :full_uri => core_uri,
  :node_id  => 1
})

Cms::Concept.create({
  :site_id   => 1,
  :parent_id => 0,
  :state     => 'public',
  :level_no  => 1,
  :sort_no   => 1,
  :name      => core_title
})

Cms::Node.create({
  :site_id      => 1,
  :concept_id   => 1,
  :parent_id    => 0,
  :route_id     => 0,
  :state        => 'public',
  :published_at => Time.now,
  :directory    => 1,
  :model        => 'Cms::Directory',
  :name         => '/',
  :title        => core_title
})

Cms::Node.create({
  :site_id      => 1,
  :concept_id   => 1,
  :parent_id    => 1,
  :route_id     => 1,
  :state        => 'public',
  :published_at => Time.now,
  :directory    => 0,
  :model        => 'Cms::Page',
  :name         => 'index.html',
  :title        => core_title
})

puts "-- seed/base success."
