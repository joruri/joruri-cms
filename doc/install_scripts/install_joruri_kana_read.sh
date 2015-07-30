#!/bin/bash
DONE_FLAG="/tmp/$0_done"

echo '#### Install Joruri (kana, read) ####'
if [ -f $DONE_FLAG ]; then exit; fi
echo '-- PRESS ENTER KEY --'
read KEY

ubuntu() {
  echo 'Ubuntu will be supported shortly.'
}

centos() {
  echo "It's CentOS!"

  yum install -y glibc-devel.i686 libstdc++-devel.i686 sox

  cd /usr/local/src
  rm -rf hts_engine_API-1.07.tar.gz hts_engine_API-1.07
  wget http://downloads.sourceforge.net/hts-engine/hts_engine_API-1.07.tar.gz
  tar zxf hts_engine_API-1.07.tar.gz && cd hts_engine_API-1.07 && ./configure CFLAGS='-m32' && make && make install

  cd /usr/local/src
  rm -rf open_jtalk-1.06.tar.gz open_jtalk-1.06
  wget http://downloads.sourceforge.net/open-jtalk/open_jtalk-1.06.tar.gz
  tar zxf open_jtalk-1.06.tar.gz && cd open_jtalk-1.06
  sed -i 's/#define MAXBUFLEN 1024/#define MAXBUFLEN 10240/' bin/open_jtalk.c
  ./configure --with-charset=UTF-8 CPPFLAGS='-m32' LDFLAGS='-m32' && make && make install

  cd /usr/local/src
  rm -rf open_jtalk_dic_utf_8-1.06.tar.gz open_jtalk_dic_utf_8-1.06
  wget http://downloads.sourceforge.net/open-jtalk/open_jtalk_dic_utf_8-1.06.tar.gz
  tar zxf open_jtalk_dic_utf_8-1.06.tar.gz
  mkdir /usr/local/share/open_jtalk && mv open_jtalk_dic_utf_8-1.06 /usr/local/share/open_jtalk/dic

  cd /usr/local/src
  rm -rf lame-3.99.5.tar.gz lame-3.99.5
  wget http://jaist.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
  tar zxf lame-3.99.5.tar.gz && cd lame-3.99.5 && ./configure && make && make install

  cd /usr/local/src
  rm -rf mecab-0.996.tar.gz mecab-0.996
  wget http://mecab.googlecode.com/files/mecab-0.996.tar.gz
  tar zxf mecab-0.996.tar.gz && cd mecab-0.996 && ./configure --enable-utf8-only && make && make install

  cd /usr/local/src
  rm -rf mecab-ipadic-2.7.0-20070801.tar.gz mecab-ipadic-2.7.0-20070801
  wget http://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz
  tar zxf mecab-ipadic-2.7.0-20070801.tar.gz && cd mecab-ipadic-2.7.0-20070801 && ./configure --with-charset=utf8 && make && make install

  cd /usr/local/src
  rm -rf mecab-ruby-0.996.tar.gz mecab-ruby-0.996
  wget http://mecab.googlecode.com/files/mecab-ruby-0.996.tar.gz
  tar zxf mecab-ruby-0.996.tar.gz && cd mecab-ruby-0.996 && ruby extconf.rb && make && make install
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
