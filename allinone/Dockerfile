FROM ubuntu:focal
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.28.5
ENV Version=${Version} \
    LANG=zh_CN.UTF-8

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends wget python3.8 python3.8-dev python3-venv curl gnupg2 ca-certificates lsb-release language-pack-zh-hans netcat gettext software-properties-common iputils-ping telnet \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && echo "deb http://nginx.org/packages/ubuntu focal nginx" > /etc/apt/sources.list.d/nginx.list \
    && echo "deb https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
    && add-apt-repository -y ppa:redislabs/redis \
    && apt-get install -y --no-install-recommends redis-server nginx supervisor logrotate mongodb-mongosh \
    && apt-get install -y --no-install-recommends libaio-dev freetds-dev freetds-dev libpq-dev libffi-dev libxml2-dev libxmlsec1-dev libxmlsec1-openssl libxslt-dev libmariadb-dev libldap2-dev libsasl2-dev openssh-client pkg-config sshpass mariadb-client bash-completion g++ make \
    && apt-get install -y --no-install-recommends libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin uuid-dev \
    && apt-get install -y --no-install-recommends libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev \
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

ARG WISP_VERSION=v0.0.10 \
    Jmservisor_VERSION=v1.2.5 \
    Client_VERSION=v1.1.7 \
    MRD_VERSION=10.6.7 \
    VIDEO_PLAYER_VERSION=0.1.5 \
    PLAY_VERSION=1.1.0-1

RUN set -ex \
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && rm -f /opt/jumpserver/apps/common/utils/ip/geoip/GeoLite2-City.mmdb /opt/jumpserver/apps/common/utils/ip/ipip/ipipfree.ipdb \
    && wget https://download.jumpserver.org/files/ip/GeoLite2-City.mmdb -O /opt/jumpserver/apps/common/utils/ip/geoip/GeoLite2-City.mmdb \
    && wget https://download.jumpserver.org/files/ip/ipipfree.ipdb -O /opt/jumpserver/apps/common/utils/ip/ipip/ipipfree.ipdb \
    && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-${Version}-linux-${TARGETARCH}.tar.gz \
    && tar -xf koko-${Version}-linux-${TARGETARCH}.tar.gz \
    && mv koko-${Version}-linux-${TARGETARCH} koko \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && mv /opt/koko/helm /usr/local/bin/ \
    && chown root:root /usr/local/bin/kubectl /usr/local/bin/helm \
    && wget https://download.jumpserver.org/public/kubectl-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubectl-linux-${TARGETARCH}.tar.gz \
    && chmod 755 kubectl \
    && mv kubectl /usr/local/bin/rawkubectl \
    && wget https://download.jumpserver.org/public/helm-v3.9.0-linux-${TARGETARCH}.tar.gz -O helm.tar.gz \
    && tar -xf helm.tar.gz \
    && mv linux-${TARGETARCH}/helm /usr/local/bin/rawhelm \
    && chmod 755 /usr/local/bin/rawhelm \
    && chown root:root /usr/local/bin/rawhelm \
    && rm -rf linux-${TARGETARCH} \
    && wget http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && chmod 755 /opt/koko/init-kubectl.sh \
    && wget https://github.com/jumpserver/lion-release/releases/download/${Version}/lion-${Version}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${Version}-linux-${TARGETARCH}.tar.gz \
    && mv lion-${Version}-linux-${TARGETARCH} lion \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && mv wisp-${WISP_VERSION}-linux-${TARGETARCH}/wisp /usr/local/bin/ \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -rf wisp-${WISP_VERSION}-linux-${TARGETARCH} \
    && wget https://github.com/jumpserver/magnus-release/releases/download/${Version}/magnus-${Version}-linux-${TARGETARCH}.tar.gz \
    && tar -xf magnus-${Version}-linux-${TARGETARCH}.tar.gz \
    && mv magnus-${Version}-linux-${TARGETARCH} /opt/magnus \
    && chmod 755 /opt/magnus/magnus \
    && chown -R root:root /opt/magnus \
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
    && rm -f /opt/jumpserver/apps/locale/zh/LC_MESSAGES/django.mo /opt/jumpserver/apps/locale/zh/LC_MESSAGES/djangojs.mo \
    && python manage.py compilemessages \
    && rm -f /opt/jumpserver/config.yml \
    && /etc/init.d/redis-server stop \
    && cd /opt \
    && echo > /etc/nginx/conf.d/default.conf \
    && chown -R root:root /opt/* \
    && echo ". /opt/py3/bin/activate" >> ~/.bashrc \
    && mkdir -p /opt/download /opt/player \
    && cd /opt/download \
    && wget -qO /opt/download/Jmservisor.msi https://download.jumpserver.org/public/Jmservisor-${Jmservisor_VERSION}.msi \
    && wget -qO /opt/download/JumpServer-Client-Installer-x86_64.msi https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-x86_64.msi \
    && wget -qO /opt/download/JumpServer-Client-Installer.dmg https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}.dmg \
    && wget -qO /opt/download/JumpServer-Client-Installer-amd64.run https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-amd64.run \
    && wget -qO /opt/download/JumpServer-Client-Installer-arm64.run https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-arm64.run \
    && wget -qO /opt/download/JumpServer-Video-Player.dmg https://download.jumpserver.org/public/JumpServer.Video.Player-${VIDEO_PLAYER_VERSION}.dmg \
    && wget -qO /opt/download/JumpServer-Video-Player.exe https://download.jumpserver.org/public/JumpServer.Video.Player.Setup.${VIDEO_PLAYER_VERSION}.exe \
    && wget -qO /opt/download/OpenSSH-Win64.msi https://download.jumpserver.org/public/OpenSSH-Win64.msi \
    && wget -q https://download.jumpserver.org/public/Microsoft_Remote_Desktop_${MRD_VERSION}_installer.pkg \
    && wget -q https://download.jumpserver.org/public/glyptodon-enterprise-player-${PLAY_VERSION}.tar.gz \
    && tar -xf glyptodon-enterprise-player-${PLAY_VERSION}.tar.gz -C /opt/player --strip-components 1 \
    && rm -f glyptodon-enterprise-player-${PLAY_VERSION}.tar.gz \
    && rm -f /etc/cron.daily/apt-compat \
    && rm -f /opt/*.tar.gz \
    && rm -rf /opt/guacamole-server-1.4.0 \
    && rm -rf ~/.cache/pip

COPY allinone/readme.txt readme.txt
COPY allinone/entrypoint.sh .
COPY allinone/jumpserver.conf /etc/nginx/conf.d/
COPY allinone/supervisord.conf /etc/supervisor/conf.d/
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /opt/lion/data
VOLUME /opt/magnus/data

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
