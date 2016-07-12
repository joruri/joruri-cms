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

  file_name = '/var/share/joruri/config/rsync.yml'

  buffer = File.open(file_name, 'r') do |file|
    file.read()
  end

  pattern = <<EOS
production:
  transfer_log: false
  transfer_to_publish: false
  transfer_opts: "-rlptvz --delete"
  transfer_opt_remote_shell: "ssh -p 22"
  transfer_dest_user:
  transfer_dest_host:
  transfer_dest_dir:
EOS

  replacement = <<EOS
production:
  transfer_log: false
  transfer_to_publish: true
  transfer_opts: "-rlptvz --delete"
  transfer_opt_remote_shell: "ssh -p 22"
  transfer_dest_user: joruri
  transfer_dest_host: #{ENV["WEB_IPADDR"]}
  transfer_dest_dir: /var/share/joruri
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
