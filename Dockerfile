FROM ubuntu:18.04
WORKDIR /opt
ARG DEBIAN_FRONTEND=noninteractive
COPY sources.list /etc/apt/sources.list
RUN apt-get -y update && \
    apt-get -y upgrade
	
RUN apt-get -y install tzdata apt-utils language-pack-zh-hans 
RUN apt-get -y install python3 python3-pip libmysqlclient-dev sshpass \
        nginx redis supervisor python-tk python-dev \
        libtiff5-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev \
        libwebp-dev tcl8.5-dev tk8.5-dev  openssl libssl-dev libldap2-dev \
        libsasl2-dev libkrb5-dev vim net-tools
RUN echo 'LANG="zh_CN.UTF-8"' > /etc/default/locale

COPY jumpserver jumpserver
COPY coco coco
RUN pip3 install -r jumpserver/requirements/requirements.txt && \
    pip3 install -r coco/requirements/requirements.txt
	
VOLUME /opt/luna
VOLUME /opt/coco/keys
VOLUME /opt/jumpserver/data

COPY luna luna
COPY default /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENV DB_ENGINE=mysql \
    DB_HOST=192.168.1.20 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jms

EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]