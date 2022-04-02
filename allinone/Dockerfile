FROM ubuntu:focal
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.20.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && apt-get update \
    && apt-get install -y wget curl gnupg2 ca-certificates lsb-release language-pack-en netcat redis-server gettext \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && echo "deb http://nginx.org/packages/ubuntu focal nginx" > /etc/apt/sources.list.d/nginx.list \
    && wget -O /etc/apt/trusted.gpg.d/nginx_signing.asc https://nginx.org/keys/nginx_signing.key \
    && apt-get install -y python3.8 python3.8-dev python3-venv libaio-dev freetds-dev freetds-dev pkg-config libpq-dev libffi-dev libxml2-dev libxmlsec1-dev libxmlsec1-openssl libxslt-dev libmariadb-dev libldap2-dev libsasl2-dev sshpass mariadb-client bash-completion g++ make \
    && apt-get install -y libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin uuid-dev \
    && apt-get install -y libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev \
    && python3.8 -m venv /opt/py3 \
    && wget http://download.jumpserver.org/public/guacamole-server-1.4.0.tar.gz \
    && tar -xf guacamole-server-1.4.0.tar.gz \
    && cd guacamole-server-1.4.0 \
    && ./configure --with-init-dir=/etc/init.d  --disable-guaclog \
    && make \
    && make install \
    && ldconfig \
    && cd /opt \
    && rm -rf guacamole-server-1.4.0 guacamole-server-1.4.0.tar.gz \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && apt-get update \
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && wget https://download.jumpserver.org/files/GeoLite2-City.mmdb -O /opt/jumpserver/apps/common/utils/geoip/GeoLite2-City.mmdb \
    && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-${Version}-linux-${TARGETARCH}.tar.gz \
    && tar -xf koko-${Version}-linux-${TARGETARCH}.tar.gz \
    && mv koko-${Version}-linux-${TARGETARCH} koko \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && wget https://download.jumpserver.org/public/kubectl-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubectl-linux-${TARGETARCH}.tar.gz \
    && chmod 755 kubectl \
    && mv kubectl /usr/local/bin/rawkubectl \
    && wget http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && chmod 755 /opt/koko/init-kubectl.sh \
    && wget https://github.com/jumpserver/lion-release/releases/download/${Version}/lion-${Version}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${Version}-linux-${TARGETARCH}.tar.gz \
    && mv lion-${Version}-linux-${TARGETARCH} lion \
    && wget https://github.com/jumpserver/lina/releases/download/${Version}/lina-${Version}.tar.gz \
    && tar -xf lina-${Version}.tar.gz \
    && mv lina-${Version} lina \
    && wget https://github.com/jumpserver/luna/releases/download/${Version}/luna-${Version}.tar.gz \
    && tar -xf luna-${Version}.tar.gz \
    && mv luna-${Version} luna \
    && . /opt/py3/bin/activate \
    && pip install --upgrade pip \
    && pip install --upgrade setuptools \
    && pip install --upgrade wheel \
    && pip install $(grep -E 'PyNaCl' /opt/jumpserver/requirements/requirements.txt) \
    && pip install grpcio==1.41.1 \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && cd /opt/jumpserver/apps \
    && sed -i "561i maxmemory-policy allkeys-lru" /etc/redis/redis.conf \
    && /etc/init.d/redis-server start \
    && echo "SECRET_KEY: $(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 49)" > /opt/jumpserver/config.yml \
    && rm -f /opt/jumpserver/apps/locale/zh/LC_MESSAGES/django.mo \
    && python manage.py compilemessages \
    && rm -f /opt/jumpserver/config.yml \
    && /etc/init.d/redis-server stop \
    && cd /opt \
    && apt-get install -y nginx supervisor \
    && echo > /etc/nginx/conf.d/default.conf \
    && chown -R root:root /opt/* \
    && echo ". /opt/py3/bin/activate" >> ~/.bashrc \
    && apt-get clean all \
    && rm -rf /opt/guacamole-server-1.4.0 \
    && rm -rf /opt/*.tar.gz \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf ~/.cache/pip

COPY allinone/readme.txt readme.txt
COPY allinone/entrypoint.sh .
COPY allinone/jumpserver.conf /etc/nginx/conf.d/
COPY allinone/supervisord.conf /etc/supervisor/conf.d/
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /opt/lion/data

ENV SECRET_KEY=kWQdmdCQKjaWlHYpPhkNQDkfaRulM6YnHctsHLlSPs8287o2kW \
    BOOTSTRAP_TOKEN=KXOeyNgDeTdpeu9q \
    DB_ENGINE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jumpserver \
    REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD=weakPassword \
    CORE_HOST=http://127.0.0.1:8080 \
    LOG_LEVEL=ERROR

EXPOSE 80 2222
ENTRYPOINT ["./entrypoint.sh"]
