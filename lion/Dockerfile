FROM ubuntu:focal
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.20.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && apt-get update \
    && apt-get install -y wget curl gnupg2 ca-certificates lsb-release language-pack-en netcat \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && apt-get install -y make \
    && apt-get install -y libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin uuid-dev \
    && apt-get install -y libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && wget http://download.jumpserver.org/public/guacamole-server-1.4.0.tar.gz \
    && tar -xf guacamole-server-1.4.0.tar.gz \
    && cd guacamole-server-1.4.0 \
    && ./configure --with-init-dir=/etc/init.d --disable-guaclog \
    && make \
    && make install \
    && ldconfig \
    && cd /opt \
    && rm -rf /opt/guacamole-server-1.4.0 /opt/guacamole-server-1.4.0.tar.gz

RUN set -ex \
    && wget https://github.com/jumpserver/lion-release/releases/download/${Version}/lion-${Version}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${Version}-linux-${TARGETARCH}.tar.gz \
    && mv lion-${Version}-linux-${TARGETARCH} lion \
    && chown -R root:root /opt/lion \
    && rm -rf /opt/*.tar.gz

COPY lion/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
