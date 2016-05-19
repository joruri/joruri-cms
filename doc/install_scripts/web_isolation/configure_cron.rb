#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_web_isolation_done"

puts '#### configure cron ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  system %q(su - joruri -c 'cd /var/share/joruri && bundle exec whenever --clear-crontab')

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
