FROM centos:7
RUN yum update -y && yum install epel-release -y && yum update -y && yum install -y wget unzip epel-release nginx sqlite-devel xz gcc automake zlib-devel openssl-devel redis mariadb mariadb-devel mariadb-server supervisor
WORKDIR /opt/

# 下载包并解压
RUN wget https://github.com/jumpserver/jumpserver/archive/master.zip -O /opt/jumpserver.zip
RUN wget https://github.com/jumpserver/coco/archive/dev.zip -O /opt/coco.zip
RUN wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz -O /opt/Python-3.6.1.tar.xz
RUN wget https://github.com/jumpserver/luna/releases/download/0.5-beta-2/luna.tar.gz -O /opt/luna.tar.gz
RUN unzip coco.zip && mv coco-dev coco && unzip jumpserver.zip && mv jumpserver-master jumpserver && tar xzf luna.tar.gz

# 准备python
RUN tar xf Python-3.6.1.tar.xz  && cd Python-3.6.1 && ./configure && make && make install
RUN python3 -m venv py3

# 安装yum依赖
RUN yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) && yum -y install $(cat /opt/coco/requirements/rpm_requirements.txt)

# 安装pip依赖
RUN source /opt/py3/bin/activate && pip install --upgrade pip && pip install -r /opt/jumpserver/requirements/requirements.txt &&  pip install -r /opt/coco/requirements/requirements.txt

# 准备目录
RUN mkdir -p /opt/nginx/log && chmod 777 /opt/nginx/log/
RUN mkdir -p /opt/mysql/log /opt/mysql/data /opt/mysql/plugin 
RUN ln -s /opt/mysql/mysql.sock  /var/lib/mysql/mysql.sock

# mysql基本表结构
RUN mysql_install_db
RUN chown -R mysql:mysql /opt/mysql

# 准备配置文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY mysql.cnf /etc/my.cnf
COPY errmsg.sys /opt/mysql/share/mysql/errmsg.sys
COPY jumpserver_conf.py /opt/jumpserver/config.py

ENV DB_HOST=localhost DB_PORT=3306 DB_USER=jumpserver DB_PASSWORD=weakPassword DB_NAME=jumpserver
ENV REDIS_HOST=localhost REDIS_PORT=6379

EXPOSE 2222 80
CMD ["/usr/bin/supervisord"]
