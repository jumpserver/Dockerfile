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
    && apt-get install -y python3.8 python3.8-dev python3-venv libaio-dev freetds-dev freetds-dev pkg-config libpq-dev libffi-dev libxml2-dev libxmlsec1-dev libxmlsec1-openssl libxslt-dev libmariadb-dev libldap2-dev libsasl2-dev sshpass g++ make \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && wget https://download.jumpserver.org/files/GeoLite2-City.mmdb -O /opt/jumpserver/apps/common/utils/geoip/GeoLite2-City.mmdb \
    && chown -R root:root jumpserver \
    && python3.8 -m venv /opt/py3 \
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
    && echo ". /opt/py3/bin/activate" >> ~/.bashrc \
    && rm -rf /opt/*.tar.gz \
    && rm -rf ~/.cache/pip

COPY core/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
