FROM ubuntu:18.04
WORKDIR /opt
ARG DEBIAN_FRONTEND=noninteractive
COPY sources.list /etc/apt/sources.list
RUN apt-get -y update && \
    apt-get -y upgrade

RUN apt-get -y install tzdata apt-utils language-pack-zh-hans
RUN apt-get -y install wget libkrb5-dev libsqlite3-dev gcc \
    make automake libssl-dev zlib1g-dev libmysqlclient-dev \
    libffi-dev git xz-utils supervisor sshpass
RUN echo 'LANG="zh_CN.UTF-8"' > /etc/default/locale

COPY jumpserver jumpserver
COPY coco coco
COPY luna luna

RUN cd /opt/jumpserver/requirements && \
    apt-get -y install $(cat deb_requirements.txt)

COPY Python-3.6.1.tar.xz Python-3.6.1.tar.xz
RUN tar xf Python-3.6.1.tar.xz
RUN cd Python-3.6.1/ && ./configure && make && make install
RUN python3 -m venv /opt/py3

RUN apt-get -y install redis-server nginx

RUN /opt/py3/bin/pip install -r jumpserver/requirements/requirements.txt && \
    /opt/py3/bin/pip install -r coco/requirements/requirements.txt

VOLUME /opt/luna
VOLUME /opt/coco/keys
VOLUME /opt/jumpserver/data

RUN rm -rf Python*

COPY default /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

ENV DB_ENGINE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jms

ENV REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=

EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]
