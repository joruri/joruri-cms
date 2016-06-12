#!/bin/bash
DONE_FLAG="/tmp/$0_done"

RUBY_VERSION='ruby-2.1.5'
RUBY_SOURCE_URL="http://cache.ruby-lang.org/pub/ruby/2.1/$RUBY_VERSION.tar.bz2"

echo "#### Install $RUBY_VERSION ####"
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  yum install -y wget gcc-c++ patch libyaml-* libjpeg-devel libpng-devel librsvg2-devel ghostscript-devel curl-devel nkfreadline-devel zlib-devel openssl-devel

  cd /usr/local/src
  rm -rf $RUBY_VERSION.tar.bz2 $RUBY_VERSION
  wget $RUBY_SOURCE_URL
  tar jxf $RUBY_VERSION.tar.bz2 && cd $RUBY_VERSION && ./configure && make && make install

  gem update --system

  gem install bundler
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
