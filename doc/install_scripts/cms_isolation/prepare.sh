#!/bin/bash

INSTALL_SCRIPTS_URL='https://raw.githubusercontent.com/joruri/joruri-cms/v3-develop/doc/install_scripts/cms_isolation'

echo '#### Prepare to install ####'

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  mkdir /usr/local/src/cms_isolation

  cd /usr/local/src/cms_isolation

  files=('configure_mysql.rb' 'configure_file_sync.rb' 'configure_joruri.rb')

  rm -f install_scripts.txt
  for file in ${files[@]}; do
    echo "$INSTALL_SCRIPTS_URL/$file" >> install_scripts.txt
  done

  wget -i install_scripts.txt

  for file in ${files[@]}; do
    chmod 755 $file
  done

  rm -f install_all.sh

  echo ". /etc/profile" >> install_all.sh

  # SET OS_VERSION
  if [ "`cat /etc/redhat-release | grep 'CentOS release 6.'`" ]; then
    echo "OS_VERSION='centos6'" >> install_all.sh
  else
    echo "OS_VERSION='centos7'" >> install_all.sh
  fi
  echo "export OS_VERSION" >> install_all.sh


  # INPUT IPADDR
  echo "-------"
  echo -n "接続するWEBサーバーのIPアドレスを入力してください："
  while :
    do
      read ipaddr
      if [[ "$ipaddr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          break;
      else
          echo -n 'Re-enter:'
      fi
    done
  echo "WEB_IPADDR='$ipaddr'" >> install_all.sh
  echo "export WEB_IPADDR" >> install_all.sh


  for file in ${files[@]}; do
    echo "./$file" >> install_all.sh
  done

cat <<'EOF' >> install_all.sh

echo "
-- WEBサーバーの設定に進んでください。 --
"
EOF
  chmod 755 install_all.sh

echo '
-- インストールを続けるには以下のコマンドを実行してください。 --

# cd /usr/local/src/cms_isolation && /usr/local/src/cms_isolation/install_all.sh
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
