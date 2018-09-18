FROM centos:7.5.1804
WORKDIR /opt
RUN yum update -y
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    export LC_ALL=zh_CN.UTF-8 && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf
RUN yum -y install wget sqlite-devel xz gcc automake zlib-devel openssl-devel epel-release git make

RUN git clone https://github.com/jumpserver/jumpserver.git
RUN git clone https://github.com/jumpserver/coco.git
RUN wget https://github.com/jumpserver/luna/releases/download/1.4.1/luna.tar.gz

RUN tar xvf luna.tar.gz
RUN chown -R root:root luna

COPY luna luna
COPY config.py jumpserver/config.py
COPY conf.py coco/conf.py

RUN yum -y install redis nginx supervisor
RUN systemctl enable redis && \
    systemctl enable nginx && \
    systemctl enable supervisord

RUN cd /opt/jumpserver/requirements && \
    yum -y install $(cat rpm_requirements.txt)

RUN cd /opt/coco/requirements && \
    yum -y install $(cat rpm_requirements.txt)

RUN wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz
RUN tar xf Python-3.6.1.tar.xz
RUN cd Python-3.6.1/ && ./configure && make && make install

RUN python3 -m venv /opt/py3

RUN source /opt/py3/bin/activate && \
    pip install -r jumpserver/requirements/requirements.txt && \
    pip install -r coco/requirements/requirements.txt

VOLUME /opt/luna
VOLUME /opt/coco/keys
VOLUME /opt/jumpserver/data

RUN rm -rf Python*
RUN rm -rf luna.tar.gz

COPY nginx.conf /etc/nginx/nginx.conf
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
