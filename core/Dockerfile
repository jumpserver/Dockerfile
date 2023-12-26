FROM jumpserver/python:3.11-slim-buster as stage-1
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        git                           \
        git-lfs                       \
        wget"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

WORKDIR /opt

ARG VERSION=v3.10.0
ENV VERSION=$VERSION

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/jumpserver/jumpserver /opt/jumpserver \
    && sed -i "s@VERSION = .*@VERSION = \"${VERSION}\"@g" /opt/jumpserver/apps/jumpserver/const.py \
    && chmod +x /opt/jumpserver/entrypoint.sh \
    && rm -f /opt/jumpserver/Dockerfile \
    && rm -rf /opt/jumpserver/.git /opt/jumpserver/.github

WORKDIR /opt/jumpserver

RUN set -ex \
    && wget -q https://github.com/wojiushixiaobai/jumpserver-patch/raw/master/core/Dockerfile-ce \
    && cd utils \
    && bash -ixeu build.sh

FROM jumpserver/python:3.11-slim-buster as stage-2
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

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${BUILD_DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && echo "no" | dpkg-reconfigure dash

WORKDIR /opt

ARG RUST_VERSION=1.71.1
RUN set -ex \
    && \
    if [ "${TARGETARCH}" == "s390x" ] || [ "${TARGETARCH}" == "ppc64le" ] || [ "${TARGETARCH}" == "loong64" ]; then \
        rustUrl="https://static.rust-lang.org/dist"; \
        rustArch="${TARGETARCH}"; \
        mkdir -p /opt/rust-install; \
        if [ "${TARGETARCH}" == "loong64" ]; then \
            rustUrl="download.jumpserver.org/rust/dist"; \
            rustArch="loongarch64"; \
        fi; \
        if [ "${TARGETARCH}" == "ppc64le" ]; then \
            rustArch="powerpc64le"; \
        fi; \
        wget -O /opt/rust.tar.gz "${rustUrl}/rust-${RUST_VERSION}-${rustArch}-unknown-linux-gnu.tar.xz"; \
        tar -xf /opt/rust.tar.gz -C /opt/rust-install --strip-components=1; \
        cd /opt/rust-install && ./install.sh; \
        cd /opt && rm -rf /opt/rust-install /opt/rust.tar.gz; \
        mkdir -p ${CARGO_HOME:-$HOME/.cargo}; \
        echo -e '[source.crates-io]\nreplace-with = "ustc"\n\n[source.ustc]\nregistry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"' > ${CARGO_HOME:-$HOME/.cargo}/config; \
    fi

COPY --from=stage-1 /opt/jumpserver/poetry.lock /opt/jumpserver/pyproject.toml /opt/jumpserver/

WORKDIR /opt/jumpserver

ARG PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1

RUN --mount=type=cache,target=/root/.cache \
    set -ex \
    && python3 -m venv /opt/py3 \
    && pip install $(grep cryptography pyproject.toml | sed 's/ = /==/g' | sed 's/"//g') \
    && pip install poetry \
    && poetry config virtualenvs.create false \
    && . /opt/py3/bin/activate \
    && poetry install --only=main

FROM jumpserver/python:3.11-slim-buster
ARG TARGETARCH
ENV LANG=zh_CN.UTF-8 \
    PATH=/opt/py3/bin:$PATH

ARG DEPENDENCIES="                    \
        libjpeg-dev                   \
        libx11-dev                    \
        libxmlsec1-openssl"

ARG TOOLS="                           \
        ca-certificates               \
        curl                          \
        default-libmysqlclient-dev    \
        default-mysql-client          \
        iputils-ping                  \
        locales                       \
        nmap                          \
        openssh-client                \
        patch                         \
        sshpass                       \
        telnet                        \
        vim                           \
        wget"

RUN set -ex \
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
    && sed -i "s@# alias @alias @g" ~/.bashrc

COPY --from=stage-2 /opt/py3 /opt/py3
COPY --from=stage-1 /opt/jumpserver/release/jumpserver /opt/jumpserver

WORKDIR /opt/jumpserver

ARG VERSION=v3.10.0
ENV VERSION=${VERSION}

VOLUME /opt/jumpserver/data

EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]