FROM jumpserver/python:3.9-slim-buster
ARG TARGETARCH
ENV LANG=zh_CN.UTF-8

ARG BUILD_DEPENDENCIES="              \
        g++                           \
        make                          \
        pkg-config"

ARG DEPENDENCIES="                    \
        freetds-dev                   \
        libpq-dev                     \
        libffi-dev                    \
        libjpeg-dev                   \
        libldap2-dev                  \
        libsasl2-dev                  \
        libssl-dev                    \
        libxml2-dev                   \
        libxmlsec1-dev                \
        libxmlsec1-openssl            \
        freerdp2-dev                  \
        libaio-dev"

ARG TOOLS="                           \
        ca-certificates               \
        curl                          \
        default-libmysqlclient-dev    \
        default-mysql-client          \
        git                           \
        git-lfs                       \
        iputils-ping                  \
        locales                       \
        netcat                        \
        openssh-client                \
        procps                        \
        sshpass                       \
        telnet                        \
        unzip                         \
        vim                           \
        wget"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${BUILD_DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && mkdir -p /root/.ssh/ \
    && echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n\tCiphers +aes128-cbc\n\tKexAlgorithms +diffie-hellman-group1-sha1\n\tHostKeyAlgorithms +ssh-rsa" > /root/.ssh/config \
    && echo "set mouse-=a\nset ts=4\nset expandtab" > ~/.vimrc \
    && echo "no" | dpkg-reconfigure dash \
    && echo "zh_CN.UTF-8" | dpkg-reconfigure locales \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

ARG VERSION=v3.4.3
ENV VERSION=${VERSION}

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/jumpserver/jumpserver /opt/jumpserver \
    && sed -i "s@VERSION = .*@VERSION = \"${VERSION}\"@g" /opt/jumpserver/apps/jumpserver/const.py \
    && chmod +x /opt/jumpserver/entrypoint.sh \
    && rm -rf /opt/jumpserver/.git /opt/jumpserver/.github

WORKDIR /opt/jumpserver

RUN set -ex \
    && echo > /opt/jumpserver/config.yml \
    && pip install --upgrade pip \
    && pip install --upgrade setuptools wheel \
    && \
    if [ "${TARGETARCH}" == "loong64" ]; then \
        pip install https://download.jumpserver.org/pypi/simple/cryptography/cryptography-38.0.4-cp39-cp39-linux_loongarch64.whl; \
        pip install https://download.jumpserver.org/pypi/simple/greenlet/greenlet-1.1.2-cp39-cp39-linux_loongarch64.whl; \
        pip install https://download.jumpserver.org/pypi/simple/PyNaCl/PyNaCl-1.5.0-cp39-cp39-linux_loongarch64.whl; \
        pip install https://download.jumpserver.org/pypi/simple/grpcio/grpcio-1.54.2-cp39-cp39-linux_loongarch64.whl; \
    fi \
    && pip install -r requirements/requirements.txt \
    && rm -rf /root/.cache/pip

WORKDIR /opt/jumpserver
VOLUME /opt/jumpserver/data
VOLUME /opt/jumpserver/logs

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]