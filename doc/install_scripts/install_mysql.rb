#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_done"

puts '#### Install MySQL ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  system 'yum install -y mysql-server'

  my_cnf = '/etc/my.cnf'

  if `grep -s ^character-set-server= #{my_cnf}`.empty? && `grep -s ^default-character-set= #{my_cnf}`.empty?
    FileUtils.copy(my_cnf, "#{my_cnf}.#{Time.now.strftime('%Y%m%d%H%M')}", preserve: true)

    File.open(my_cnf, File::RDWR) do |f|
      f.flock(File::LOCK_EX)

      cnf = f.read

      cnf.concat("\n[mysqld]\n") unless cnf.index(/^\[mysqld\]$/)
      cnf.sub!(/^\[mysqld\]$/) {|m| "#{m}\ncharacter-set-server=utf8" }
      cnf.concat("\n[client]\n") unless cnf.index(/^\[client\]$/)
      cnf.sub!(/^\[client\]$/) {|m| "#{m}\ndefault-character-set=utf8" }

      f.rewind
      f.write cnf
      f.flush
      f.truncate(f.pos)

      f.flock(File::LOCK_UN)
    end
  end

  unless system 'mysqladmin ping' # Not required to connect
    system 'mysql_install_db --user=mysql'
    system 'service mysqld start'
    sleep 1 until system 'mysqladmin ping' # Not required to connect
    system "mysqladmin -u root password 'pass'"
    system %q!mysql -u root -ppass -e "GRANT ALL ON joruri.* TO joruri@localhost IDENTIFIED BY 'pass'"!
    system 'service mysqld stop'
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
