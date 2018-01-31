#!/bin/bash
# coding: utf-8
# Copyright (c) 2018
# Gmail: liuzheng712
#

set -ex

yum update -y
yum install epel-release -y
yum update -y 
yum install wget unzip epel-release nginx sqlite-devel xz gcc automake zlib-devel openssl-devel redis mariadb mariadb-devel mariadb-server supervisor -y

source /dev/stdin <<<  "$(curl https://raw.githubusercontent.com/jumpserver/Dockerfile/mysql/alpine/require.txt)" 

cd /opt/ 
curl -o ${Python_dist}  ${Python_URL}
curl -o ${Jumpserver_dist}  ${Jumpserver_URL}
curl -o ${Coco_dist} ${Coco_URL}
curl -o ${Luna_dist} ${Luna_URL} 

tar xf ${Python_dist}
unzip ${Jumpserver_dist}
unzip ${Coco_dist}
tar xzf ${Luna_dist}
mv coco-dev coco
mv jumpserver-dev jumpserver


cd /opt/Python* && ./configure && make && make install
cd /opt/
python3 -m venv py3
source /opt/py3/bin/activate

yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt)

pip install -r /opt/jumpserver/requirements/requirements.txt
pip install -r /opt/coco/requirements/requirements.txt

mkdir -p /opt/mysql/ /opt/mysql/share/mysql/ /etc/nginx/
curl -o /opt/mysql/mysql_security.sql  ${nginxip}/mysql_security.sql
curl -o /etc/my.cnf  ${nginxip}/mysql.cnf
curl -o /opt/mysql/share/mysql/errmsg.sys  ${nginxip}/errmsg.sys

curl -o /etc/nginx/nginx.conf  ${nginxip}/nginx.conf
curl -o /etc/supervisord.conf  ${nginxip}/supervisord.conf
curl -o /opt/jumpserver/config.py  ${nginxip}/jumpserver_conf.py
curl -o /opt/start_jms.sh  ${nginxip}/start_jms.sh

