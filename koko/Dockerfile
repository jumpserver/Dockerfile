FROM debian:10
WORKDIR /opt
ARG Version=v2.6.2
ENV Version=${Version} \
    LANG=en_US.utf8

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
    && sed -i "s@# export LS_OPTIONS@export LS_OPTIONS@g" ~/.bashrc \
    && sed -i "s@# alias l@alias l@g" ~/.bashrc \
    && rm -rf /opt/*.tar.gz \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY koko/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD [ "./entrypoint.sh" ]
