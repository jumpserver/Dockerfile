#!/bin/bash
#

echo -e "# 1. 安装基本RPM\n"
yum update -y && yum install epel-release -y && yum update -y && yum install wget unzip epel-release nginx sqlite-devel xz gcc automake zlib-devel openssl-devel redis mariadb mariadb-devel mariadb-server supervisor -y

echo -e "# 2. 下载包并解压\n"
wget https://github.com/jumpserver/jumpserver/archive/dev.zip -O /opt/jumpserver.zip
wget https://github.com/jumpserver/coco/archive/dev.zip -O /opt/coco.zip
wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz -O /opt/Python-3.6.1.tar.xz
wget https://github.com/jumpserver/luna/releases/download/0.5-beta-2/luna.tar.gz -O /opt/luna.tar.gz
unzip coco.zip && mv coco-dev coco && unzip jumpserver.zip && mv jumpserver-master jumpserver && tar xzf luna.tar.gz

echo -e "# 3. 准备python\n"
tar xf Python-3.6.1.tar.xz  && cd Python-3.6.1 && ./configure && make && make install
python3 -m venv py3

echo -e "# 4. 安装yum依赖\n"
RUN yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) && yum -y install $(cat /opt/coco/requirements/rpm_requirements.txt)

echo -e "# 5. 安装pip依赖\n"
source /opt/py3/bin/activate && pip install --upgrade pip && pip install -r /opt/jumpserver/requirements/requirements.txt &&  pip install -r /opt/coco/requirements/requirements.txt

echo -e "# 6. 准备目录\n"
RUN mkdir -p /opt/nginx/log && chmod 777 /opt/nginx/log/
RUN mkdir -p /opt/mysql/log /opt/mysql/data /opt/mysql/plugin
RUN ln -s /opt/mysql/mysql.sock  /var/lib/mysql/mysql.sock

echo -e "# 7. mysql基本表结构\n"
mysql_install_db
chown -R mysql:mysql /opt/mysql
cp mysql_security.sql /opt/mysql/mysql_security.sql
service mariadb start && mysql < /opt/mysql/mysql_security.sql

echo -e "# 8. 准备配置文件\n"
cp nginx.conf /etc/nginx/nginx.conf
cp supervisord.conf /etc/supervisord.conf
cp mysql.cnf /etc/my.cnf
cp errmsg.sys /opt/mysql/share/mysql/errmsg.sys
cp jumpserver_conf.py /opt/jumpserver/config.py

echo -e "# 9. # 准备启动jms的脚本\n"
cp start_jms.sh /opt/start_jms.sh
chmod +x /opt/start_jms.sh
