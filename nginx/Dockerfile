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
    && echo "deb http://nginx.org/packages/ubuntu focal nginx" > /etc/apt/sources.list.d/nginx.list \
    && wget -O /etc/apt/trusted.gpg.d/nginx_signing.asc https://nginx.org/keys/nginx_signing.key \
    && apt-get update \
    && apt-get install -y nginx \
    && echo > /etc/nginx/conf.d/default.conf \
    && wget https://github.com/jumpserver/luna/releases/download/${Version}/luna-${Version}.tar.gz \
    && tar -xf luna-${Version}.tar.gz \
    && mv luna-${Version} luna \
    && wget https://github.com/jumpserver/lina/releases/download/${Version}/lina-${Version}.tar.gz \
    && tar -xf lina-${Version}.tar.gz \
    && mv lina-${Version} lina \
    && rm -rf /opt/*.tar.gz \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY nginx/nginx.conf /etc/nginx/

CMD ["nginx", "-g", "daemon off;"]
