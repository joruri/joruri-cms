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

  yum install -y ImageMagick-devel libxml2-devel libxslt-devel mysql-devel openldap-devel

  git clone https://github.com/joruri/joruri-cms.git /var/share/joruri

  cp /var/share/joruri/config/original/* /var/share/joruri/config/

  cp -r /var/share/joruri/public/_common/themes/joruri.original /var/share/joruri/public/_common/themes/joruri

  chown -R joruri:joruri /var/share/joruri
  su - joruri -c 'cd /var/share/joruri && bundle install --path vendor/bundle --without development test'

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
