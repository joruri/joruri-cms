#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_cms_isolation_done"

puts '#### configure mysql ####'
exit if File.exist?(DONE_FLAG)
puts '-- PRESS ENTER KEY --'
gets

require 'fileutils'

def ubuntu
  puts 'Ubuntu will be supported shortly.'
end

def centos
  puts "It's CentOS!"

  my_cnf = '/etc/my.cnf'

  if `grep -s ^log-bin=mysql-bin= #{my_cnf}`.empty? && `grep -s ^server-id= #{my_cnf}`.empty?
    FileUtils.copy(my_cnf, "#{my_cnf}.#{Time.now.strftime('%Y%m%d%H%M')}", preserve: true)

    File.open(my_cnf, File::RDWR) do |f|
      f.flock(File::LOCK_EX)

      cnf = f.read

      cnf.concat("\n[mysqld]\n") unless cnf.index(/^\[mysqld\]$/)
      cnf.sub!(/^\[mysqld\]$/) do |m|
        "#{m}\n" +\
        "log-bin=mysql-bin\n" +\
        "server-id=1\n" +\
        "expire_logs_days=7\n"
      end

      f.rewind
      f.write cnf
      f.flush
      f.truncate(f.pos)

      f.flock(File::LOCK_UN)
    end
  end

  if ENV["OS_VERSION"] == 'centos6'
    system 'service mysqld restart'
  else
    system 'systemctl restart mysqld.service'
  end

  sleep 1 until system 'mysqladmin ping -u root -prootpass'

  system %Q(mysql -u root -prootpass -e "GRANT REPLICATION SLAVE ON *.* TO repl@'#{ENV["WEB_IPADDR"]}' IDENTIFIED BY 'replpass'")

  # lock
  system %q(mysql -u root -prootpass -e "FLUSH TABLES WITH READ LOCK;")

  # get master status
  repl_config = { file: nil, position: nil }

  status = `mysql -u root -prootpass -e "show master status\\G"`

  md = status.match(/File: (mysql-bin\.[0-9]+)/)
  if md
    repl_config[:file] = md[1]
  end

  md = status.match(/Position: ([0-9]+)/)
  if md
    repl_config[:position] = md[1].to_i
  end

  # unlock
  system %q(mysql -u root -prootpass -e "UNLOCK TABLES;")

  # master dump
  system %q(mysqldump -u root -prootpass joruri_production > /home/joruri/joruri_production.dmp)


  puts "\n"
  puts '-----以下を確認してから設定を進めてください。-----'
  puts "\n"
  puts '1.以下のダンプファイルをWEBサーバの同じディレクトリにコピーしてください。'
  puts `ls /home/joruri/joruri_production.dmp`
  puts "\n"

  puts '2.下記の設定値をメモしてください。WEBサーバ側でMySQLレプリケーション設定に利用します。'
  puts "File: #{repl_config[:file]}"
  puts "Position: #{repl_config[:position]}"
  puts "\n"

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
