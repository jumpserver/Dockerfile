FROM wojiushixiaobai/basics:latest
LABEL maintainer "wojiushixiaobai"
WORKDIR /opt

ENV GUAC_VER=0.9.14

RUN set -ex \
    && git clone https://github.com/jumpserver/jumpserver.git \
    && git clone https://github.com/jumpserver/coco.git \
    && wget https://github.com/jumpserver/luna/releases/download/1.4.6/luna.tar.gz \
    && tar xf luna.tar.gz \
    && chown -R root:root luna \
    && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) \
    && yum -y install $(cat /opt/coco/requirements/rpm_requirements.txt) \
    && python3.6 -m venv /opt/py3 \
    && source /opt/py3/bin/activate \
    && pip install --upgrade pip setuptools \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && pip install -r /opt/coco/requirements/requirements.txt \
    && cd /config \
    && git clone https://github.com/jumpserver/docker-guacamole.git \
    && cd docker-guacamole \
    && tar xf guacamole-server-${GUAC_VER}.tar.gz \
    && cd guacamole-server-${GUAC_VER} \
    && autoreconf -fi \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && cd .. \
    && cp guacamole-${GUAC_VER}.war /config/tomcat8/webapps/ROOT.war \
    && cp guacamole-auth-jumpserver-${GUAC_VER}.jar /config/guacamole/extensions \
    && cp root/app/guacamole/guacamole.properties /config/guacamole \
    && ldconfig \
    && cd /config \
    && wget https://github.com/ibuler/ssh-forward/releases/download/v0.0.5/linux-amd64.tar.gz \
    && tar xf linux-amd64.tar.gz -C /bin/ \
    && chmod +x /bin/ssh-forward \
    && mkdir -p /opt/coco/keys /opt/coco/logs \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /opt/luna.tar.gz \
    && rm -rf /var/cache/yum/* \
    && rm -rf ~/.cache/pip \
    && rm -rf /config/linux-amd64.tar.gz \
    && rm -rf /config/docker-guacamole

COPY config.py jumpserver/config.py
COPY conf.py coco/conf.py
COPY nginx.conf /etc/nginx/nginx.conf
COPY readme.txt readme.txt
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/coco/keys
VOLUME /config/guacamole/keys
VOLUME /var/lib/mysql

ENV BOOTSTRAP_TOKEN=nwv4RdXpM82LtSvmV

ENV DB_ENGINE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jumpserver

ENV REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=

ENV JUMPSERVER_KEY_DIR=/config/guacamole/keys \
    GUACAMOLE_HOME=/config/guacamole \
    JUMPSERVER_ENABLE_DRIVE=true \
    JUMPSERVER_SERVER=http://127.0.0.1:8080

EXPOSE 2222 80
ENTRYPOINT ["entrypoint.sh"]
