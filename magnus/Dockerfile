FROM ubuntu:focal
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.20.3
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && apt-get update \
    && apt-get install -y wget curl gnupg2 ca-certificates lsb-release language-pack-en netcat \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && apt-get install -y mariadb-client bash-completion \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && wget https://github.com/jumpserver/magnus-release/releases/download/${Version}/magnus-${Version}-linux-${TARGETARCH}.tar.gz \
    && mkdir /opt/magnus \
    && tar -xf magnus-${Version}-linux-${TARGETARCH}.tar.gz -C /opt/magnus \
    && mv /opt/magnus/magnus-linux-${TARGETARCH} /opt/magnus/magnus \
    && chmod +x /opt/magnus/magnus

COPY magnus/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD [ "./entrypoint.sh" ]
