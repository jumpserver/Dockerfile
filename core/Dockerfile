FROM ubuntu:focal
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.9.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && apt-get update \
    && apt-get install -y wget curl gnupg2 ca-certificates lsb-release language-pack-en netcat \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && apt-get install -y python3.8 python3.8-dev python3-venv libffi-dev libxml2 libxslt-dev libmariadb-dev libldap2-dev libsasl2-dev sshpass gcc make \
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && chown -R root:root jumpserver \
    && python3.8 -m venv /opt/py3 \
    && . /opt/py3/bin/activate \
    && pip install --upgrade pip==20.2.4 setuptools==49.6.0 wheel==0.34.2 \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && echo ". /opt/py3/bin/activate" >> ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /opt/*.tar.gz \
    && rm -rf ~/.cache/pip

COPY core/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
