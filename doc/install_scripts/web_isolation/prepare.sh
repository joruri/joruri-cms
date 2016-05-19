#!/bin/bash

INSTALL_SCRIPTS_URL='https://raw.githubusercontent.com/joruri/joruri-cms/v3-develop/doc/install_scripts/web_isolation'

echo '#### Prepare to install ####'

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  mkdir /usr/local/src/web_isolation

  cd /usr/local/src/web_isolation

  files=('configure_cron.rb' 'configure_mysql.rb' 'configure_joruri.rb')

  rm -f install_scripts.txt
  for file in ${files[@]}; do
    echo "$INSTALL_SCRIPTS_URL/$file" >> install_scripts.txt
  done

  wget -i install_scripts.txt

  for file in ${files[@]}; do
    chmod 755 $file
  done

  rm -f install_all.sh

  # SET OS_VERSION
  if [ "`cat /etc/redhat-release | grep 'CentOS release 6.'`" ]; then
    echo "OS_VERSION='centos6'" >> install_all.sh
  else
    echo "OS_VERSION='centos7'" >> install_all.sh
  fi
  echo "export OS_VERSION" >> install_all.sh


  # INPUT IPADDR
  echo "-------"
  echo -n "接続するCMSサーバのIPアドレスを入力してください:"
  while :
    do
      read ipaddr
      if [[ "$ipaddr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          break;
      else
          echo -n 'Re-enter:'
      fi
    done
#  echo $ipaddr
  echo "CMS_IPADDR='$ipaddr'" >> install_all.sh
  echo "export CMS_IPADDR" >> install_all.sh

  echo "MySQLマスターデータベースのスタータスを入力してください"
  echo -n "File:"
  while :
    do
      read repl_file
      if [[ "$repl_file" =~ ^mysql-bin\.[0-9]+$ ]]; then
          break;
      else
          echo -n 'Re-enter:'
      fi
    done
#  echo $repl_file
  echo "REPL_FILE='$repl_file'" >> install_all.sh
  echo "export REPL_FILE" >> install_all.sh
  echo -n "Position:"
  while :
    do
      read repl_positoin
      if [[ "$repl_positoin" =~ ^[0-9]+$ ]]; then
          break;
      else
          echo -n 'Re-enter:'
      fi
    done
#  echo $repl_positoin
  echo "REPL_POSITION=$repl_positoin" >> install_all.sh
  echo "export REPL_POSITION" >> install_all.sh



  for file in ${files[@]}; do
    echo "./$file" >> install_all.sh
  done

cat <<'EOF' >> install_all.sh

echo "
-- WEBサーバの設定を完了しました。 --
"
EOF
  chmod 755 install_all.sh

echo '
-- インストールを続けるには以下のコマンドを実行してください。 --

# cd /usr/local/src/web_isolation && /usr/local/src/web_isolation/install_all.sh
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
