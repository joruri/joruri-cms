#!/bin/bash

EPEL_RPM_URL="http://dl.fedoraproject.org/pub/epel/6/`uname -i`/epel-release-6-8.noarch.rpm"
MYSQL_REPO_URL="http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm"
INSTALL_SCRIPTS_URL='https://raw.githubusercontent.com/joruri/joruri-cms/v3-develop/doc/install_scripts'

echo '#### Prepare to install ####'

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS6!"

  rpm -ivh $EPEL_RPM_URL
  yum -y install $MYSQL_REPO_URL
  yum -y install wget git

  cd /usr/local/src

  files=('install_ruby.sh' 'install_joruri.sh' 'install_apache.rb' 'install_mysql.rb'
         'configure_joruri.rb' 'install_joruri_kana_read.sh' 'start_servers.sh' 'install_cron.sh')

  rm -f install_scripts.txt
  for file in ${files[@]}; do
    echo "$INSTALL_SCRIPTS_URL/$file" >> install_scripts.txt
  done

  wget -i install_scripts.txt

  for file in ${files[@]}; do
    chmod 755 $file
  done

  rm -f install_all.sh
  for file in ${files[@]}; do
    echo "./$file" >> install_all.sh
    if [ $file = 'install_ruby.sh' ]; then
      echo ". /etc/profile.d/rbenv.sh" >> install_all.sh
    fi
  done
cat <<'EOF' >> install_all.sh

echo "
-- インストールを完了しました。 --

  公開画面: `ruby -ryaml -e "puts YAML.load_file('/var/share/joruri/config/core.yml')['production']['uri']"`

  管理画面: `ruby -ryaml -e "puts YAML.load_file('/var/share/joruri/config/core.yml')['production']['uri']"`_admin

    管理者（システム管理者）
    ユーザID   : joruri
    パスワード : joruri

１．MySQL の root ユーザはパスワードが rootpass に設定されています。適宜変更してください。
    # mysqladmin -u root -prootpass password 'newpass'
２．MySQL の joruri ユーザはパスワードが joruripass に設定されています。適宜変更してください。
    mysql> SET PASSWORD FOR joruri@localhost = PASSWORD('newpass');
    また、変更時には /var/share/joruri/config/database.yml も合わせて変更してください。
    # vi /var/share/joruri/config/database.yml
３．OS の joruri ユーザに cron が登録されています。
    # crontab -u joruri -e
"
EOF
  chmod 755 install_all.sh

echo '
-- インストールを続けるには以下のコマンドを実行してください。 --

# cd /usr/local/src && /usr/local/src/install_all.sh
'
}

others() {
  echo 'This OS is not supported.'
  exit
}

if [ -f /etc/centos-release ]; then
  centos
elif [ -f /etc/lsb-release ]; then
  if grep -qs Ubuntu /etc/lsb-release; then
    ubuntu
  else
    others
  fi
else
  others
fi
