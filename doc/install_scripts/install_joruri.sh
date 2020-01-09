#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Install Joruri ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  if [ -d /var/share/joruri ]; then
    echo 'Joruri is already installed.'
    exit
  fi

  id joruri || useradd -m joruri

  yum -y install freetype-devel harfbuzz-devel fribidi-devel gtk-doc
  yum -y install --enablerepo=remi ImageMagick6-devel
  yum install -y libxml2-devel libxslt-devel mysql-devel openldap-devel nodejs patch

  git clone -b master https://github.com/joruri/joruri-cms.git /var/share/joruri

  chown -R joruri:joruri /var/share/joruri

  cp -p /var/share/joruri/config/original/application.yml /var/share/joruri/config/application.yml

  su - joruri -c 'export LANG=ja_JP.UTF-8; cd /var/share/joruri && bundle _1.17.3_ install --path vendor/bundle --without development test'
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

touch $DONE_FLAG
