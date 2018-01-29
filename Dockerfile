FROM centos:7

# 1. 安装基本依赖
RUN yum update -y && yum install epel-release -y && yum update -y && yum install wget unzip epel-release nginx sqlite-devel xz gcc automake zlib-devel openssl-devel redis mariadb mariadb-devel mariadb-server supervisor -y
WORKDIR /opt/

# 2. 准备python
RUN wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz -O /opt/Python-3.6.1.tar.xz
RUN tar xf Python-3.6.1.tar.xz  && cd Python-3.6.1 && ./configure && make && make install
RUN python3 -m venv py3

# 3. 下载包并解压
RUN wget https://github.com/jumpserver/jumpserver/archive/dev.zip -O /opt/jumpserver.zip
RUN wget https://github.com/jumpserver/coco/archive/dev.zip -O /opt/coco.zip
RUN wget https://github.com/jumpserver/luna/releases/download/0.5-beta-2/luna.tar.gz -O /opt/luna.tar.gz
RUN unzip coco.zip && mv coco-dev coco && unzip jumpserver.zip && mv jumpserver-dev jumpserver && tar xzf luna.tar.gz

# 4. 安装yum依赖
RUN yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) && yum -y install $(cat /opt/coco/requirements/rpm_requirements.txt)

# 5. 安装pip依赖
RUN source /opt/py3/bin/activate && pip install --upgrade pip && pip install -r /opt/jumpserver/requirements/requirements.txt &&  pip install -r /opt/coco/requirements/requirements.txt

VOLUME /opt/coco/keys

# 7. 准备文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY jumpserver_conf.py /opt/jumpserver/config.py
COPY coco_conf.py /opt/coco/conf.py
COPY start_jms.sh /opt/start_jms.sh

ENV REDIS_HOST=127.0.0.1 REDIS_PORT=6379

EXPOSE 2222 80
CMD ["/usr/bin/supervisord"]