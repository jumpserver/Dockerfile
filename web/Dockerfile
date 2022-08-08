FROM ubuntu:focal
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.24.2 \
    Jmservisor_VERSION=v1.2.3 \
    Client_VERSION=v1.1.6 \
    MRD_VERSION=10.6.7 \
    VIDEO_PLAYER_VERSION=0.1.5
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
    && mkdir -p /opt/download \
    && cd /opt/download \
    && wget -q https://download.jumpserver.org/public/Microsoft_Remote_Desktop_${MRD_VERSION}_installer.pkg \
    && wget -qO /opt/download/Jmservisor.msi https://download.jumpserver.org/public/Jmservisor-${Jmservisor_VERSION}.msi \
    && wget -qO /opt/download/JumpServer-Client-Installer-x86_64.msi https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-x86_64.msi \
    && wget -qO /opt/download/JumpServer-Client-Installer.dmg https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}.dmg \
    && wget -qO /opt/download/JumpServer-Client-Installer-amd64.run https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-amd64.run \
    && wget -qO /opt/download/JumpServer-Client-Installer-arm64.run https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-arm64.run \
    && wget -qO /opt/download/JumpServer-Video-Player.dmg https://jms-pkg.oss-cn-beijing.aliyuncs.com/public/JumpServer.Video.Player-${VIDEO_PLAYER_VERSION}.dmg \
    && wget -qO /opt/download/JumpServer-Video-Player.exe https://jms-pkg.oss-cn-beijing.aliyuncs.com/public/JumpServer.Video.Player.Setup.${VIDEO_PLAYER_VERSION}.exe \
    && rm -rf /var/log/nginx/*.log \
    && rm -rf /opt/*.tar.gz \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY web/nginx.conf /etc/nginx/

CMD ["nginx", "-g", "daemon off;"]