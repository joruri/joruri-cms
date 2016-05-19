#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_web_isolation_done"

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

  file_name = '/etc/httpd/conf.d/joruri.conf'
  File.open(file_name, 'a') do |file|
    file.puts ''
    file.puts '<Location /_admin>'
    file.puts '  Order deny,allow'
    file.puts '  Deny from all'
    file.puts '</Location>'
  end

  if ENV["OS_VERSION"] == 'centos6'
    system 'service httpd restart'
  else
    system 'systemctl restart httpd.service'
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
