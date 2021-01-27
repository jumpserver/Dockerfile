FROM debian:10
WORKDIR /opt
ARG Version=v2.6.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends curl wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get -y install --no-install-recommends gcc netcat net-tools telnet \
    && apt-get -y install --no-install-recommends python3-venv python3.7-dev \
    && apt-get -y install --no-install-recommends default-libmysqlclient-dev libldap2-dev libsasl2-dev libsasl2-dev \
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && chown -R root:root jumpserver \
    && python3 -m venv /opt/py3 \
    && . /opt/py3/bin/activate \
    && pip --no-cache-dir install wheel \
    && pip --no-cache-dir install -r /opt/jumpserver/requirements/requirements.txt \
    && echo ". /opt/py3/bin/activate" >> ~/.bashrc \
    && sed -i "s@# export LS_OPTIONS@export LS_OPTIONS@g" ~/.bashrc \
    && sed -i "s@# alias l@alias l@g" ~/.bashrc \
    && rm -f /opt/*.tar.gz \
    && rm -rf ~/.cache/pip \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends curl wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get -y install --no-install-recommends netcat net-tools telnet \
    && apt-get -y install --no-install-recommends bash-completion mariadb-client \
    && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-${Version}-linux-amd64.tar.gz \
    && tar -xf koko-${Version}-linux-amd64.tar.gz \
    && mv koko-${Version}-linux-amd64 koko \
    && chown -R root:root koko \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && wget https://download.jumpserver.org/public/kubectl.tar.gz \
    && tar -xf kubectl.tar.gz \
    && chmod 755 ./kubectl \
    && chown root:root ./kubectl \
    && mv kubectl /usr/local/bin/rawkubectl \
    && wget http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && chmod 755 /opt/koko/init-kubectl.sh \
    && rm -rf /opt/*.tar.gz \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends curl wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get -y install --no-install-recommends netcat net-tools telnet \
    && apt-get -y install --no-install-recommends tomcat9 \
    && apt-get -y install --no-install-recommends libcairo2-dev libjpeg62-turbo-dev	libpng-dev libtool-bin libossp-uuid-dev \
    && apt-get -y install --no-install-recommends	libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev \
    && mkdir -p /config/guacamole/lib /config/guacamole/extensions /config/guacamole/data/log/ /config/guacamole/data/record /config/guacamole/data/drive \
    && cd /config \
    && wget -O docker-guacamole-${Version}.tar.gz https://github.com/jumpserver/docker-guacamole/archive/master.tar.gz \
    && mkdir /config/docker-guacamole \
    && tar -xf docker-guacamole-${Version}.tar.gz -C /config/docker-guacamole --strip-components 1 \
    && rm -rf docker-guacamole-${Version}.tar.gz \
    && chown -R root:root /config/docker-guacamole \
    && cd /config/docker-guacamole \
    && wget http://download.jumpserver.org/public/guacamole-server-1.3.0.tar.gz \
    && tar -xf guacamole-server-1.3.0.tar.gz \
    && cd guacamole-server-1.3.0 \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig \
    && cd .. \
    && wget http://download.jumpserver.org/public/ssh-forward.tar.gz \
    && tar -xf ssh-forward.tar.gz -C /bin/ \
    && chmod 755 /bin/ssh-forward \
    && wget http://download.jumpserver.org/release/${Version}/guacamole-client-${Version}.tar.gz \
    && tar -xf guacamole-client-${Version}.tar.gz \
    && rm -rf /var/lib/tomcat9/webapps/* \
    && cp guacamole-client-${Version}/guacamole-*.war /var/lib/tomcat9/webapps/ROOT.war \
    && cp guacamole-client-${Version}/guacamole-*.jar /config/guacamole/extensions/ \
    && cd /config \
    && mv /config/docker-guacamole/guacamole.properties /config/guacamole/ \
    && rm -rf /config/docker-guacamole \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends curl wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get -y install --no-install-recommends netcat net-tools telnet \
    && echo "deb http://nginx.org/packages/debian buster nginx" >> /etc/apt/sources.list.d/nginx.list \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && apt-get update \
    && apt-get -y install --no-install-recommends nginx \
    && echo > /etc/nginx/conf.d/default.conf \
    && wget -O /etc/nginx/conf.d/jumpserver.conf https://demo.jumpserver.org/download/nginx/conf.d/jms_all.conf \
    && wget https://github.com/jumpserver/luna/releases/download/${Version}/luna-${Version}.tar.gz \
    && tar -xf luna-${Version}.tar.gz \
    && mv luna-${Version} luna \
    && wget https://github.com/jumpserver/lina/releases/download/${Version}/lina-${Version}.tar.gz \
    && tar -xf lina-${Version}.tar.gz \
    && mv lina-${Version} lina \
    && sed -i "s@worker_processes  1;@worker_processes  auto;@g" /etc/nginx/nginx.conf \
    && rm -rf /opt/*.tar.gz \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY allinone/readme.txt readme.txt
COPY allinone/entrypoint.sh .
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /config/guacamole/data

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
    REDIS_PASSWORD= \
    CORE_HOST=http://127.0.0.1:8080 \
    DEBUG=FALSE \
    LOG_LEVEL=ERROR \
    JUMPSERVER_KEY_DIR=/config/guacamole/data/keys \
    GUACAMOLE_HOME=/config/guacamole \
    GUACAMOLE_LOG_LEVEL=ERROR \
    JUMPSERVER_ENABLE_DRIVE=true \
    JUMPSERVER_RECORD_PATH=/config/guacamole/data/record \
    JUMPSERVER_DRIVE_PATH=/config/guacamole/data/drive \
    JUMPSERVER_CLEAR_DRIVE_SESSION=true \
    JUMPSERVER_CLEAR_DRIVE_SCHEDULE=24 \
    JUMPSERVER_SERVER=http://127.0.0.1:8080 \
    JUMPSERVER_COLOR_DEPTH=32 \
    JUMPSERVER_DPI=120 \
    JUMPSERVER_DISABLE_BITMAP_CACHING=true \
    JUMPSERVER_DISABLE_GLYPH_CACHING=true

EXPOSE 80 2222
ENTRYPOINT ["./entrypoint.sh"]
