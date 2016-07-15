#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_cms_isolation_done"

puts '#### configure joruri ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  file_name = '/var/share/joruri/config/database.yml'

  buffer = File.open(file_name, 'r') do |file|
    file.read()
  end

  pattern = <<EOS
#production_pull_database:
#  adapter : mysql2
#  database: joruri_production
#  username: joruri
#  password: joruripass
#  timeout : 5000
#  encoding: utf8
#  reconnect: true
#  host:
EOS

  replacement = <<EOS
production_pull_database:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: joruri_production
  pool: 5
  username: joruri
  password: joruripass
  host: #{ENV['WEB_IPADDR']}
EOS

  buffer.sub!(pattern, replacement)

  File.open(file_name, 'w') do |file|
    file.write(buffer)
  end

  system %q(su - joruri -c 'touch /var/share/joruri/tmp/restart.txt')

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
