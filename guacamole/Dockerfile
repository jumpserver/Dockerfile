FROM debian:10
WORKDIR /opt
ARG Version=v2.6.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends curl wget ca-certificates \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get -y install --no-install-recommends netcat net-tools telnet \
    && apt-get -y install --no-install-recommends tomcat9 make gcc autoconf make automake \
    && apt-get -y install --no-install-recommends freerdp2-dev libcairo2-dev libjpeg62-turbo-dev libossp-uuid-dev libpango1.0-dev libpulse-dev libssh2-1-dev libssl-dev libtelnet-dev libtool libvncserver-dev libwebsockets-dev libwebp-dev \
    && mkdir -p /config/guacamole/lib /config/guacamole/extensions /config/guacamole/data/log/ /config/guacamole/data/record /config/guacamole/data/drive \
    && cd /config \
    && wget -O docker-guacamole-${Version}.tar.gz https://github.com/jumpserver/docker-guacamole/archive/master.tar.gz \
    && mkdir /config/docker-guacamole \
    && tar -xf docker-guacamole-${Version}.tar.gz -C /config/docker-guacamole --strip-components 1 \
    && rm -rf docker-guacamole-${Version}.tar.gz \
    && chown -R root:root /config/docker-guacamole \
    && cd /config/docker-guacamole \
    && wget http://download.jumpserver.org/public/guacamole-server-1.2.0.tar.gz \
    && tar -xf guacamole-server-1.2.0.tar.gz \
    && cd guacamole-server-1.2.0 \
    && mkdir -p /usr/local/guacamole /tmp/guacd-docker-BUILD \
    && export PREFIX_DIR=/usr/local/guacamole \
    && export BUILD_DIR=/tmp/guacd-docker-BUILD \
    && export LD_LIBRARY_PATH=${PREFIX_DIR}/lib \
    && cp -r src/guacd-docker/bin "${PREFIX_DIR}/bin/" \
    && cp -r . "$BUILD_DIR" \
    && sed -i "s@./configure@./configure --with-init-dir=/etc/init.d@g" ${PREFIX_DIR}/bin/build-guacd.sh \
    && ${PREFIX_DIR}/bin/build-guacd.sh "$BUILD_DIR" "$PREFIX_DIR" \
    && ${PREFIX_DIR}/bin/list-dependencies.sh ${PREFIX_DIR}/sbin/guacd ${PREFIX_DIR}/lib/libguac-client-*.so ${PREFIX_DIR}/lib/freerdp2/guac*.so > ${PREFIX_DIR}/DEPENDENCIES \
    && apt-get -y install --no-install-recommends ghostscript fonts-liberation fonts-dejavu xfonts-terminus \
    && apt-get -y install --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && ${PREFIX_DIR}/bin/link-freerdp-plugins.sh ${PREFIX_DIR}/lib/freerdp2/libguac*.so \
    && cd /config/docker-guacamole \
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
    && rm -rf "$BUILD_DIR" \
    && sed -i "s@# export LS_OPTIONS@export LS_OPTIONS@g" ~/.bashrc \
    && sed -i "s@# alias l@alias l@g" ~/.bashrc \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY guacamole/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
