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
    && apt-get install -y mariadb-client bash-completion redis \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
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
    && rm -rf /opt/*.tar.gz

COPY koko/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD [ "./entrypoint.sh" ]
