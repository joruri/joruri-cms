#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_done"

PASSENGER_VERSION = '4.0.53'

puts '#### Install Apache ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  system 'yum install -y httpd-devel shared-mime-info'

  httpd_conf = '/etc/httpd/conf/httpd.conf'

  if `grep -s ^ServerName #{httpd_conf}`.empty?
    FileUtils.copy(httpd_conf, "#{httpd_conf}.#{Time.now.strftime('%Y%m%d%H%M')}", preserve: true)

    File.open(httpd_conf, File::RDWR) do |f|
      f.flock(File::LOCK_EX)

      conf = f.read

      f.rewind
      f.write conf.sub(/^#ServerName .*$/) {|m| "#{m}\nServerName #{`hostname`.chomp}" }
      f.flush
      f.truncate(f.pos)

      f.flock(File::LOCK_UN)
    end
  end

  passenger_conf = '/etc/httpd/conf.d/passenger.conf'

  unless File.exist?(passenger_conf)
    system 'yum install -y curl-devel'
    system "gem install passenger -v #{PASSENGER_VERSION}"
    system 'passenger-install-apache2-module -a'

    File.open(passenger_conf, File::RDWR|File::CREAT, 0644) do |f|
      f.flock(File::LOCK_EX)

      conf = File.read('/var/share/joruri/config/samples/passenger.conf')

      f.write conf.gsub(/PASSENGER_VERSION/, PASSENGER_VERSION)
      f.flush
      f.truncate(f.pos)

      f.flock(File::LOCK_UN)
    end
  end
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
