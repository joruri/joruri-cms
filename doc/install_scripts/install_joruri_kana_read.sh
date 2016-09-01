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

  yum -y install sox

  cd /usr/local/src
  rm -rf hts_engine_API-1.09.tar.gz hts_engine_API-1.09
  curl -fsSLO http://ufpr.dl.sourceforge.net/project/hts-engine/hts_engine%20API/hts_engine_API-1.09/hts_engine_API-1.09.tar.gz
  tar zxf hts_engine_API-1.09.tar.gz && cd hts_engine_API-1.09 && ./configure CFLAGS='-O3 -march=native -funroll-loops' && make && make install

  cd /usr/local/src
  rm -rf open_jtalk-1.08.tar.gz open_jtalk-1.08
  curl -fsSLO http://ufpr.dl.sourceforge.net/project/open-jtalk/Open%20JTalk/open_jtalk-1.08/open_jtalk-1.08.tar.gz
  tar zxf open_jtalk-1.08.tar.gz && cd open_jtalk-1.08
  sed -i 's/#define MAXBUFLEN 1024/#define MAXBUFLEN 10240/' bin/open_jtalk.c
  ./configure --with-charset=UTF-8 CFLAGS='-O3 -march=native -funroll-loops' CXXFLAGS='-O3 -march=native -funroll-loops' && make && make install

  cd /usr/local/src
  rm -rf open_jtalk_dic_utf_8-1.08.tar.gz open_jtalk_dic_utf_8-1.08
  curl -fsSLO http://ufpr.dl.sourceforge.net/project/open-jtalk/Dictionary/open_jtalk_dic-1.08/open_jtalk_dic_utf_8-1.08.tar.gz
  tar zxf open_jtalk_dic_utf_8-1.08.tar.gz
  mkdir /usr/local/share/open_jtalk && mv open_jtalk_dic_utf_8-1.08 /usr/local/share/open_jtalk/dic

  cd /usr/local/src
  rm -rf lame-3.99.5.tar.gz lame-3.99.5
  curl -fsSLO http://jaist.dl.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
  tar zxf lame-3.99.5.tar.gz && cd lame-3.99.5 && ./configure && make && make install

  cd /usr/local/src
  rm -rf mecab-0.996.tar.gz mecab-0.996
  curl -fsSL 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' -o mecab-0.996.tar.gz
  tar zxf mecab-0.996.tar.gz && cd mecab-0.996 && ./configure --enable-utf8-only && make && make install

  cd /usr/local/src
  rm -rf mecab-ipadic-2.7.0-20070801.tar.gz mecab-ipadic-2.7.0-20070801
  curl -fsSL 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' -o mecab-ipadic-2.7.0-20070801.tar.gz
  tar zxf mecab-ipadic-2.7.0-20070801.tar.gz && cd mecab-ipadic-2.7.0-20070801 && ./configure --with-charset=utf8 && make && make install

  cd /usr/local/src
  rm -rf mecab-ruby-0.996.tar.gz mecab-ruby-0.996
  curl -fsSL 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7VUNlczBWVDZJbE0' -o mecab-ruby-0.996.tar.gz
  tar zxf mecab-ruby-0.996.tar.gz && cd mecab-ruby-0.996 && ruby extconf.rb && make && make install

  echo '/usr/local/lib' >> /etc/ld.so.conf.d/usrlocal.conf
  sudo ldconfig
  ldconfig -p | grep "/usr/local/lib"
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
