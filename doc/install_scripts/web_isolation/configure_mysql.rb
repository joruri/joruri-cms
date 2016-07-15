#!/usr/bin/env ruby
DONE_FLAG = "/tmp/#{$0}_web_isolation_done"

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

  dmp_name = '/home/joruri/joruri_production.dmp'

  unless File.exist?(dmp_name)
    puts "File not found. #{dmp_name}"
    exit
  end

  if ENV["OS_VERSION"] == 'centos6'
    system 'service httpd stop'
  else
    system 'systemctl stop httpd.service'
  end

  system %q(su - joruri -c 'cd /var/share/joruri && bundle exec whenever --clear-crontab')

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
        "relay-log=relay-log\n" +\
        "server-id=2\n" +\
        "replicate-do-db=joruri_production\n" +\
        "replicate-ignore-table=joruri_production.cms_kana_dictionaries\n" +\
        "replicate-ignore-table=joruri_production.cms_link_checks\n" +\
        "replicate-ignore-table=joruri_production.cms_stylesheets\n" +\
        "replicate-ignore-table=joruri_production.cms_talk_tasks\n" +\
        "replicate-ignore-table=joruri_production.enquete_answer_columns\n" +\
        "replicate-ignore-table=joruri_production.enquete_answers\n" +\
        "replicate-ignore-table=joruri_production.entity_conversion_logs\n" +\
        "replicate-ignore-table=joruri_production.entity_conversion_units\n" +\
        "replicate-ignore-table=joruri_production.newsletter_logs\n" +\
        "replicate-ignore-table=joruri_production.newsletter_members\n" +\
        "replicate-ignore-table=joruri_production.newsletter_requests\n" +\
        "replicate-ignore-table=joruri_production.newsletter_testers\n" +\
        "replicate-ignore-table=joruri_production.sessions\n" +\
        "replicate-ignore-table=joruri_production.simple_captcha_data\n" +\
        "replicate-ignore-table=joruri_production.sys_editable_groups\n" +\
        "replicate-ignore-table=joruri_production.sys_ldap_synchros\n" +\
        "replicate-ignore-table=joruri_production.sys_maintenances\n" +\
        "replicate-ignore-table=joruri_production.sys_messages\n" +\
        "replicate-ignore-table=joruri_production.sys_object_privileges\n" +\
        "replicate-ignore-table=joruri_production.sys_operation_logs\n" +\
        "replicate-ignore-table=joruri_production.sys_processes\n" +\
        "replicate-ignore-table=joruri_production.sys_publishers\n" +\
        "replicate-ignore-table=joruri_production.sys_recognitions\n" +\
        "replicate-ignore-table=joruri_production.sys_role_names\n" +\
        "replicate-ignore-table=joruri_production.sys_sequences\n" +\
        "replicate-ignore-table=joruri_production.sys_tasks\n" +\
        "replicate-ignore-table=joruri_production.sys_unid_relations\n" +\
        "replicate-ignore-table=joruri_production.sys_users\n" +\
        "replicate-ignore-table=joruri_production.sys_users_groups\n" +\
        "replicate-ignore-table=joruri_production.sys_users_roles\n"
      end

      f.rewind
      f.write cnf
      f.flush
      f.truncate(f.pos)

      f.flock(File::LOCK_UN)
    end
  end

  if ENV["OS_VERSION"] == 'centos6'
    system 'service httpd restart'
    system 'service mysqld restart'
  else
    system 'systemctl restart httpd.service'
    system 'systemctl restart mysqld.service'
  end

  sleep 1 until system 'mysqladmin ping -u root -prootpass'


  system %Q(mysql -u root -prootpass -e "STOP SLAVE;")

  system %q(mysql -u root -prootpass joruri_production < /home/joruri/joruri_production.dmp)

  sql_str = <<EOS
CHANGE MASTER TO
MASTER_HOST='#{ENV["CMS_IPADDR"]}',
MASTER_USER='repl',
MASTER_PASSWORD='replpass',
MASTER_LOG_FILE='#{ENV["REPL_FILE"]}',
MASTER_LOG_POS=#{ENV["REPL_POSITION"]};

TRUNCATE TABLE joruri_production.cms_kana_dictionaries;
TRUNCATE TABLE joruri_production.cms_link_checks;
TRUNCATE TABLE joruri_production.cms_stylesheets;
TRUNCATE TABLE joruri_production.cms_talk_tasks;
TRUNCATE TABLE joruri_production.enquete_answer_columns;
TRUNCATE TABLE joruri_production.enquete_answers;
TRUNCATE TABLE joruri_production.entity_conversion_logs;
TRUNCATE TABLE joruri_production.entity_conversion_units;
TRUNCATE TABLE joruri_production.newsletter_logs;
TRUNCATE TABLE joruri_production.newsletter_members;
TRUNCATE TABLE joruri_production.newsletter_requests;
TRUNCATE TABLE joruri_production.newsletter_testers;
TRUNCATE TABLE joruri_production.sessions;
TRUNCATE TABLE joruri_production.simple_captcha_data;
TRUNCATE TABLE joruri_production.sys_editable_groups;
TRUNCATE TABLE joruri_production.sys_ldap_synchros;
TRUNCATE TABLE joruri_production.sys_maintenances;
TRUNCATE TABLE joruri_production.sys_messages;
TRUNCATE TABLE joruri_production.sys_object_privileges;
TRUNCATE TABLE joruri_production.sys_operation_logs;
TRUNCATE TABLE joruri_production.sys_processes;
TRUNCATE TABLE joruri_production.sys_publishers;
TRUNCATE TABLE joruri_production.sys_recognitions;
TRUNCATE TABLE joruri_production.sys_role_names;
TRUNCATE TABLE joruri_production.sys_sequences;
TRUNCATE TABLE joruri_production.sys_tasks;
TRUNCATE TABLE joruri_production.sys_unid_relations;
TRUNCATE TABLE joruri_production.sys_users;
TRUNCATE TABLE joruri_production.sys_users_groups;
TRUNCATE TABLE joruri_production.sys_users_roles;

START SLAVE;

EOS

  system %Q(mysql -u root -prootpass -e "#{sql_str}")


  # for enqeute job
  system %Q(mysql -u root -prootpass -e "GRANT ALL PRIVILEGES ON joruri_production.* TO joruri@"#{ENV["CMS_IPADDR"]}" IDENTIFIED BY 'joruripass';")

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
