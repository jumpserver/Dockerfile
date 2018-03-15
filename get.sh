#!/bin/bash
# coding: utf-8
# Copyright (c) 2018
# Gmail: liuzheng712
#

set -ex

echo "0. 系统的一些配置"
setenforce 0 
systemctl stop iptables.service
systemctl stop firewalld.service

localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8
echo 'LANG=zh_CN.UTF-8' > /etc/sysconfig/i18n

echo "1. 安装基本依赖"
yum update -y && yum install epel-release -y && yum update -y && yum install wget unzip epel-release nginx sqlite-devel xz gcc automake zlib-devel openssl-devel redis mariadb mariadb-devel mariadb-server supervisor -y
cd /opt/

echo "2. 准备python"
wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz -O /opt/Python-3.6.1.tar.xz
RUN tar xf Python-3.6.1.tar.xz  && cd Python-3.6.1 && ./configure && make && make install
RUN python3 -m venv py3

echo "3. 下载包并解压"
wget https://github.com/jumpserver/jumpserver/archive/1.0.0.zip -O /opt/jumpserver.zip
wget https://github.com/jumpserver/coco/archive/1.0.0.zip -O /opt/coco.zip
wget https://github.com/jumpserver/luna/releases/download/v1.0.0/luna.tar.gz -O /opt/luna.tar.gz
unzip coco.zip && mv coco-1.0.0 coco && unzip jumpserver.zip && mv jumpserver-1.0.0 jumpserver && tar xzf luna.tar.gz

echo "4. 安装yum依赖"
yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) && yum -y install $(cat /opt/coco/requirements/rpm_requirements.txt)

echo "5. 安装pip依赖"
source /opt/py3/bin/activate && pip install --upgrade pip && pip install -r /opt/jumpserver/requirements/requirements.txt &&  pip install -r /opt/coco/requirements/requirements.txt

echo "6. 创建数据库"
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/mysql_security.sql?raw=true -O /opt/mysql/mysql_security.sql
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/mysql.cnf?raw=true -O /etc/my.cnf
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/errmsg.sys?raw=true -O /opt/mysql/share/mysql/errmsg.sys

echo "7. 准备文件"
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/nginx.conf?raw=true -O /etc/nginx/nginx.conf
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/supervisord.conf?raw=true -O /etc/supervisord.conf
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/jumpserver_conf.py?raw=true -O /opt/jumpserver/config.py
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/coco_conf.py?raw=true -O /opt/coco/conf.py
wget https://github.com/jumpserver/Dockerfile/blob/mysql/alpine/start_jms.sh?raw=true -O /opt/start_jms.sh

echo "8. 安装docker"
yum check-update
curl -fsSL https://get.docker.com/ | sh
systemctl start docker 
systemctl enable docker

echo "9. 安装guacamole"
host_ip=`python -c "import socket;print([(s.connect(('8.8.8.8', 53)), s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1])"`

docker run --name jms_guacamole -d \
  -p 8081:8080 -v /opt/guacamole/key:/config/guacamole/key \
  -e JUMPSERVER_KEY_DIR=/config/guacamole/key \
  -e JUMPSERVER_SERVER=http://$host_ip:8080 \
  registry.jumpserver.org/public/guacamole:1.0.0

echo "10. 配置nginx"
cat <<EOF> /etc/nginx/conf.d/jumpserver.conf 
server {
    listen 80;

    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    location /luna/ {
        try_files $uri / /index.html;
        alias /opt/luna/;
    }

    location /media/ {
        add_header Content-Encoding gzip;
        root /opt/jumpserver/data/;
    }

    location /static/ {
        root /opt/jumpserver/data/;
    }

    location /socket.io/ {
        proxy_pass       http://localhost:5000/socket.io/;  # 如果coco安装在别的服务器，请填写它的ip
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /guacamole/ {
        proxy_pass       http://localhost:8081/;  # 如果guacamole安装在别的服务器，请填写它的ip
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        access_log off;
    }

    location / {
        proxy_pass http://localhost:8080;  # 如果jumpserver安装在别的服务器，请填写它的ip
    }
}

EOF

systemctl restart nginx
systemctl enable nginx



echo " 安装完成，请运行/opt/start_jms.sh启动jumpserver"
