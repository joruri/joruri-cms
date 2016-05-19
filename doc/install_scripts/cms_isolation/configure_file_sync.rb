#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_cms_isolation_done"

puts '#### configure file_sync ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  system %q(su - joruri -c 'mkdir /home/joruri/shell')

  file_name = "/home/joruri/shell/file_sync.sh"
  str = <<EOS

rsync -avz --delete -e "ssh -p 22" /var/share/joruri/public_00000001/ #{ENV["WEB_IPADDR"]}:/var/share/joruri/public_00000001/

rsync -avz --delete -e "ssh -p 22" /var/share/joruri/upload/ #{ENV["WEB_IPADDR"]}:/var/share/joruri/upload/

EOS
  File.write(file_name, str)
  system %Q(chown joruri:joruri #{file_name})
  system %Q(chmod 700 #{file_name})


  # merge cron job
  tmp_name = '/tmp/crontab.tmp'
  system %Q(su - joruri -c 'crontab -l > #{tmp_name}')
  File.open(tmp_name, 'a') do |file|
    file.puts ''
    file.puts '# Transfer the file to Webserver'
    file.puts '*/15 * * * *  /home/joruri/shell/file_sync.sh > /home/joruri/shell/file_sync.log'
  end
  system %Q(su - joruri -c 'crontab #{tmp_name}')


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
