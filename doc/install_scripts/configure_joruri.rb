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
  db = YAML::Store.new(core_yml)
  db.transaction do
    db['production']['uri'] = "http://#{`hostname`.chomp}/"
  end

  joruri_conf = "#{config_dir}hosts/joruri.conf"
  File.open(joruri_conf, File::RDWR) do |f|
    f.flock(File::LOCK_EX)

    conf = f.read

    f.rewind
    f.write conf.gsub('joruri.example.com') {|m| `hostname`.chomp }
    f.flush
    f.truncate(f.pos)

    f.flock(File::LOCK_UN)
  end

  system "ln -s #{joruri_conf} /etc/httpd/conf.d/joruri.conf"
  system 'service mysqld start'
  sleep 1 until system 'mysqladmin ping' # Not required to connect
  system "su - joruri -c 'cd /var/share/joruri && bundle exec rake db:setup RAILS_ENV=production'"
  system "su - joruri -c 'cd /var/share/joruri && bundle exec rake db:seed RAILS_ENV=production'"
  system "su - joruri -c 'cd /var/share/joruri && bundle exec rake db:seed:demo RAILS_ENV=production'"
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
    unless `grep -s Ubuntu /etc/lsb-release`.empty?
      ubuntu
    else
      others
    end
  else
    others
  end

  system "touch #{DONE_FLAG}"
end
