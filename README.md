Joruri CMS
==========

Japan Originated Ruby-based RESTful and Integrated CMS

GNU GENERAL PUBLIC LICENSE Version 3

Copyright (C) Tokushima Prefectural Government, IDS Inc.

## 環境
* CentOS 7.2 x86_64, 6.7 x86_64
* Ruby 2.3
* Rails 4.2
* MySQL 5.6

## インストール

###### 手動インストールマニュアル
[doc/INSTALL.txt](doc/INSTALL.txt)

###### 自動インストールスクリプト
* Selinux, iptablesは無効まはた適切な設定を行っていることを想定しています。
* rootユーザで実行してください。

コマンド：

    export LANG=ja_JP.UTF-8; curl -L https://raw.githubusercontent.com/joruri/joruri-cms/v3-develop/doc/install_scripts/prepare.sh | bash


## CMSｘWEBサーバ分離構成の設定

###### 手動設定マニュアル
[doc/SERVER_ISOLATION_SETTING.txt](doc/SERVER_ISOLATION_SETTING.txt)

###### 自動設定スクリプト
* ２台のサーバにJoruriがインストールされていることを前提とします。
* 自動インストールスクリプトでインストールされた環境を想定しています。
* CMSサーバからWEBサーバへパスなしでRsyncが利用できるようにRSAキーペア認証を設定してください。（[設定マニュアル](doc/SERVER_ISOLATION_SETTING.txt)の3. RSAキーペア認証の設定を参照。）
* 以下のスクリプトはCMSサーバ、WEBサーバそれぞれの環境で実行してください。
* rootユーザで実行してください。

CMSサーバ：

    export LANG=ja_JP.UTF-8; curl -L -O https://raw.githubusercontent.com/joruri/joruri-cms/v3-develop/doc/install_scripts/cms_isolation/prepare.sh && bash prepare.sh

WEBサーバ：

    export LANG=ja_JP.UTF-8; curl -L -O https://raw.githubusercontent.com/joruri/joruri-cms/v3-develop/doc/install_scripts/web_isolation/prepare.sh && bash prepare.sh
