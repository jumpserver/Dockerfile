FROM wojiushixiaobai/python3.6.1:latest
WORKDIR /opt

RUN localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    export LC_ALL=zh_CN.UTF-8 && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf
RUN yum -y install wget sqlite-devel xz gcc automake zlib-devel openssl-devel epel-release git make

RUN git clone https://github.com/jumpserver/jumpserver.git && \
    git clone https://github.com/jumpserver/coco.git && \
    wget https://github.com/jumpserver/luna/releases/download/1.4.2/luna.tar.gz && \
    tar xf luna.tar.gz && \
    chown -R root:root luna

COPY config.py jumpserver/config.py
COPY conf.py coco/conf.py

RUN yum -y install redis nginx && \
    systemctl enable redis && \
    systemctl enable nginx

RUN cd /opt/jumpserver/requirements && \
    yum -y install $(cat rpm_requirements.txt) && \
    cd /opt/coco/requirements && \
    yum -y install $(cat rpm_requirements.txt)

RUN python3 -m venv /opt/py3 && \
    source /opt/py3/bin/activate && \
    pip install -r jumpserver/requirements/requirements.txt && \
    pip install -r coco/requirements/requirements.txt

RUN rm -rf luna.tar.gz && \
    yum clean all && \
    rm -rf /var/cache/yum/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh
RUN mkdir -p /opt/coco/keys

VOLUME /opt/coco/keys
VOLUME /opt/jumpserver/data

ENV DB_ENGINE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jumpserver

ENV REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=

EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]
