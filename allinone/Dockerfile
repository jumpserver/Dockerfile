FROM jumpserver/redis:7.0-buster as redis
FROM jumpserver/guacd:1.5.3-buster as guacd
FROM jumpserver/web-static:v1.0.4 as static
FROM jumpserver/openjdk:17-slim-buster as openjdk
FROM jumpserver/python:3.11-slim-buster as get-core
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
    && wget -q https://github.com/wojiushixiaobai/jumpserver-patch/raw/${VERSION}/core/Dockerfile-ce \
    && cd utils \
    && bash -ixeu build.sh

FROM jumpserver/python:3.11-slim-buster as build-core
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

COPY --from=get-core /opt/jumpserver/poetry.lock /opt/jumpserver/pyproject.toml /opt/jumpserver/

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
ENV LANG=zh_CN.UTF-8

ARG DEPENDENCIES="                    \
        libjpeg-dev                   \
        libx11-dev                    \
        libxmlsec1-openssl"

ARG TOOLS="                           \
        ca-certificates               \
        curl                          \
        default-libmysqlclient-dev    \
        default-mysql-client          \
        gnupg2                        \
        iputils-ping                  \
        locales                       \
        netcat                        \
        logrotate                     \
        openssh-client                \
        p11-kit                       \
        sshpass                       \
        supervisor                    \
        telnet                        \
        vim                           \
        nmap                          \
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

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends gnupg2 \
    && dpkgArch="$(dpkg --print-architecture)" \
    && case "$dpkgArch" in \
        amd64|arm64) \
            echo "deb https://nginx.org/packages/debian/ buster nginx" > /etc/apt/sources.list.d/nginx.list \
            && wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - \
            && apt-get update \
            ;; \
        loongarch64) \
            echo "deb https://download.jumpserver.org/nginx/packages/debian buster nginx" > /etc/apt/sources.list.d/nginx.list \
            && wget -qO - https://download.jumpserver.org/nginx/packages/keys/nginx_signing.key | apt-key add - \
            && apt-get update \
            ;; \
        *) \
            echo "Unsupported architecture: ${dpkgArch}" \
            ;; \
    esac \
    && apt-get -y install --no-install-recommends nginx \
    && mkdir -p /var/cache/nginx

ENV JAVA_HOME /usr/local/openjdk-17
ENV PATH $JAVA_HOME/bin:$PATH

COPY --from=openjdk $JAVA_HOME $JAVA_HOME
COPY --from=openjdk /etc/ld.so.conf.d/docker-openjdk.conf /etc/ld.so.conf.d/docker-openjdk.conf
COPY --from=openjdk /etc/ca-certificates/update.d/docker-openjdk /etc/ca-certificates/update.d/docker-openjdk

RUN set -ex \
    && chmod +x /etc/ca-certificates/update.d/docker-openjdk \
    && /etc/ca-certificates/update.d/docker-openjdk \
    && ldconfig

WORKDIR /opt

ARG MONGOSH_VERSION=1.10.6
RUN set -ex \
    && \
    case "${TARGETARCH}" in \
        amd64) \
            wget -q https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-x64/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh /usr/local/bin/ \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh_crypt_v1.so /usr/local/lib/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-x64* \
            ;; \
        arm64|s390x|ppc64le) \
            wget -q https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/mongosh /usr/local/bin/ \
            && mv mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/mongosh_crypt_v1.so /usr/local/lib/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}* \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}" \
            ;; \
    esac

ARG HELM_VERSION=v3.12.2
ARG KUBECTL_VERSION=v1.27.4
RUN set -ex \
    && \
    if [ "${TARGETARCH}" == "loong64" ]; then \
        wget -q https://download.jumpserver.org/public/kubectl-linux-${TARGETARCH}.tar.gz; \
        tar -xf kubectl-linux-${TARGETARCH}.tar.gz; \
        mv kubectl /usr/local/bin/rawkubectl; \
    else \
        wget -q -O /usr/local/bin/rawkubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl; \
    fi \
    && wget -q http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && \
    if [ "${TARGETARCH}" == "loong64" ]; then \
        wget -q https://github.com/wojiushixiaobai/helm-loongarch64/releases/download/${HELM_VERSION}/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz; \
    else \
        wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz; \
    fi \
    && tar -xf helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz -C /opt --strip-components=1 linux-${TARGETARCH}/helm \
    && mv helm /usr/local/bin/rawhelm \
    && chmod 755 /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && chown root:root /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && rm -f /opt/*.tar.gz

ARG WISP_VERSION=v0.1.16
RUN set -ex \
    && wget -q https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

ARG PREFIX_DIR=/opt/guacamole
ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib
ARG RUNTIME_DEPENDENCIES="            \
        fonts-dejavu                  \
        fonts-liberation              \
        ghostscript                   \
        netcat-openbsd                \
        xfonts-terminus"

COPY --from=guacd ${PREFIX_DIR} ${PREFIX_DIR}

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=redis /usr/local/bin/redis-cli /usr/local/bin/redis-cli
COPY --from=build-core /opt/py3 /opt/py3
COPY --from=get-core /opt/jumpserver/release/jumpserver /opt/jumpserver
COPY --from=static /opt/download /opt/download

ARG VERSION=v3.10.0
ENV VERSION=${VERSION}
ENV PATH=/opt/py3/bin:$PATH

WORKDIR /opt

RUN set -ex \
    && mkdir -p /opt/koko \
    && wget -q https://github.com/jumpserver/koko/releases/download/${VERSION}/koko-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf koko-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/koko/ --strip-components=1 \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && mv /opt/koko/helm /usr/local/bin/ \
    && chmod 755 /usr/local/bin/helm /usr/local/bin/kubectl /opt/koko/init-kubectl.sh \
    && chown root:root /usr/local/bin/helm /usr/local/bin/kubectl \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/lion \
    && wget -q https://github.com/jumpserver/lion-release/releases/download/${VERSION}/lion-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/lion --strip-components=1 \
    && chown -R root:root /opt/lion \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/magnus \
    && wget -q https://github.com/jumpserver/magnus-release/releases/download/${VERSION}/magnus-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf magnus-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/magnus --strip-components=1 \
    && chmod 755 /opt/magnus/magnus \
    && chown -R root:root /opt/magnus \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/kael \
    && wget -q https://github.com/jumpserver/kael/releases/download/${VERSION}/kael-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf kael-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/kael --strip-components=1 \
    && chmod 755 /opt/kael/kael \
    && chown -R root:root /opt/kael \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/chen \
    && wget -q https://github.com/jumpserver/chen-release/releases/download/${VERSION}/chen-${VERSION}.tar.gz \
    && tar -xf chen-${VERSION}.tar.gz -C /opt/chen --strip-components=1 \
    && chown -R root:root /opt/chen \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/lina \
    && wget -q https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && chown -R root:root /opt/lina \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/luna \
    && wget -q https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && chown -R root:root /opt/luna \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && cd /opt/download/applets \
    && wget -q https://github.com/jumpserver/applets/releases/download/${VERSION}/pip_packages.zip

COPY readme.txt readme.txt
COPY entrypoint.sh .
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /opt/lion/data
VOLUME /opt/magnus/data
VOLUME /opt/kael/data
VOLUME /opt/chen/data

EXPOSE 80 2222
ENTRYPOINT ["./entrypoint.sh"]