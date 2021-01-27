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
    && wget https://demo.jumpserver.org/download/jumpserver/${Version}/jumpserver-${Version}.tar.gz \
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

COPY core/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
