#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_done"

puts '#### Configure Joruri ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'
require 'yaml/store'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  config_dir = '/var/share/joruri/config/'

  core_yml = "#{config_dir}core.yml"
  system "cp -p #{config_dir}original/core.yml #{core_yml}"
  db = YAML::Store.new(core_yml)
  db.transaction do
    db['production']['uri'] = "http://#{`hostname`.chomp}/"
  end

  joruri_conf = "#{config_dir}hosts/joruri.conf"
  system "cp -p #{config_dir}original/hosts/joruri.conf #{joruri_conf}"
  File.open(joruri_conf, File::RDWR) do |f|
    f.flock(File::LOCK_EX)

    conf = f.read

    f.rewind
    f.write conf.gsub('joruri.example.com') { |_m| `hostname`.chomp }
    f.flush
    f.truncate(f.pos)

    f.flock(File::LOCK_UN)
  end
  system "ln -s #{joruri_conf} /etc/httpd/conf.d/joruri.conf"

  system "cp -p #{config_dir}original/smtp.yml #{config_dir}smtp.yml"

  system "cp -p #{config_dir}original/ldap.yml #{config_dir}ldap.yml"

  system "cp -p #{config_dir}samples/joruri_logrotate /etc/logrotate.d/."

  system "cp -rp /var/share/joruri/public/_common/themes/joruri.original /var/share/joruri/public/_common/themes/joruri"

  system "cp -p #{config_dir}original/database.yml #{config_dir}database.yml"

  system 'service mysqld start'

  sleep 1 until system 'mysqladmin ping' # Not required to connect

  system "su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/share/joruri && bundle exec rake db:setup RAILS_ENV=production'"

  system "su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/share/joruri && bundle exec rake db:seed:demo RAILS_ENV=production'"

  system 'service mysqld stop'
end

def others
  puts 'This OS is not supported.'
  exit
end

if __FILE__ == $0
  if File.exist? '/etc/centos-release'
    centos
  elsif File.exist? '/etc/lsb-release'
    if `grep -s Ubuntu /etc/lsb-release`.empty?
      others
    else
      ubuntu
    end
  else
    others
  end

  system "touch #{DONE_FLAG}"
end
