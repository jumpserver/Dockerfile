FROM jumpserver/redis:7.0 as redis
FROM jumpserver/guacd:1.5.2 as guacd

FROM jumpserver/python:3.11-slim-buster as stage-build
ARG TARGETARCH

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
        unzip                         \
        xz-utils                      \
        wget"

RUN RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=core \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${BUILD_DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && echo "no" | dpkg-reconfigure dash \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG RUST_VERSION=1.65.0
RUN set -ex \
    && \
    if [ "${TARGETARCH}" == "s390x" ] || [ "${TARGETARCH}" == "ppc64le" ] || [ "${TARGETARCH}" == "loong64" ]; then \
        rustUrl="https://static.rust-lang.org/dist"; \
        rustArch="${TARGETARCH}"; \
        mkdir -p /opt/rust-install; \
        if [ "${TARGETARCH}" == "loong64" ]; then \
            rustUrl="https://rust-lang.loongnix.cn/dist/2022-11-03"; \
            rustArch="loongarch64"; \
        fi; \
        if [ "${TARGETARCH}" == "ppc64le" ]; then \
            rustArch="powerpc64le"; \
        fi; \
        wget -O /opt/rust.tar.gz "${rustUrl}/rust-${RUST_VERSION}-${rustArch}-unknown-linux-gnu.tar.xz"; \
        tar -xf /opt/rust.tar.gz -C /opt/rust-install --strip-components=1; \
        cd /opt/rust-install && ./install.sh \
        cd /opt && rm -rf /opt/rust-install /opt/rust.tar.gz; \
    fi

ARG VERSION
ENV VERSION=$VERSION

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/jumpserver/jumpserver /opt/jumpserver \
    && sed -i "s@VERSION = .*@VERSION = \"${VERSION}\"@g" /opt/jumpserver/apps/jumpserver/const.py \
    && chmod +x /opt/jumpserver/entrypoint.sh \
    && rm -f /opt/jumpserver/Dockerfile /opt/jumpserver/Dockerfile-ee /opt/jumpserver/poetry.lock /opt/jumpserver/pyproject.toml \
    && rm -rf /opt/jumpserver/.git /opt/jumpserver/.github

WORKDIR /opt/jumpserver

RUN set -ex \
    && wget -q https://github.com/wojiushixiaobai/jumpserver-patch/raw/${VERSION}/core/Dockerfile-ce \
    && wget -q https://github.com/wojiushixiaobai/jumpserver-patch/raw/${VERSION}/core/Dockerfile-ee \
    && wget -q https://github.com/wojiushixiaobai/jumpserver-patch/raw/${VERSION}/core/poetry.lock \
    && wget -q https://github.com/wojiushixiaobai/jumpserver-patch/raw/${VERSION}/core/pyproject.toml \
    && cd utils \
    && bash -ixeu build.sh

RUN --mount=type=cache,target=/root/.cache \
    set -ex \
    && pip install poetry \
    && poetry config virtualenvs.create false \
    && poetry install --only=main

FROM jumpserver/python:3.11-slim-buster as stage-build
ARG TARGETARCH
ENV LANG=zh_CN.UTF-8

ARG DEPENDENCIES="                    \
        libjpeg-dev                   \
        libxmlsec1-openssl"

ARG TOOLS="                           \
        ca-certificates               \
        curl                          \
        default-libmysqlclient-dev    \
        default-mysql-client          \
        inetutils-ping                \
        locales                       \
        netcat                        \
        logrotate                     \
        openssh-client                \
        procps                        \
        sshpass                       \
        supervisor                    \
        telnet                        \
        unzip                         \
        vim                           \
        nmap                          \
        wget"

RUN RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=core \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && mkdir -p /root/.ssh/ \
    && echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n\tCiphers +aes128-cbc\n\tKexAlgorithms +diffie-hellman-group1-sha1\n\tHostKeyAlgorithms +ssh-rsa" > /root/.ssh/config \
    && echo "set mouse-=a" > ~/.vimrc \
    && echo "no" | dpkg-reconfigure dash \
    && echo "zh_CN.UTF-8" | dpkg-reconfigure locales \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && rm -rf /var/lib/apt/lists/*

COPY --from=stage-build /opt/jumpserver/release/jumpserver /opt/jumpserver
WORKDIR /opt/jumpserver

RUN --mount=type=cache,target=/root/.cache \
    set -ex \
    && echo > /opt/jumpserver/config.yml \
    && pip install poetry \
    && poetry config virtualenvs.create false \
    && poetry install --only=main

ARG VERSION=v3.7.0
ENV VERSION=${VERSION}

WORKDIR /opt/jumpserver
VOLUME /opt/jumpserver/data
VOLUME /opt/jumpserver/logs

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]