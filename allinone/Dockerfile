FROM redis:7.0-bookworm as redis
FROM jumpserver/guacd:1.5.3-bookworm as guacd
FROM jumpserver/web-static:v1.0.6-bookworm as static
FROM python:3.11-slim-bookworm as get-core
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        git                           \
        git-lfs                       \
        wget"

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES}  \
    && echo "no" | dpkg-reconfigure dash \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG VERSION=v3.10.2
ENV VERSION=$VERSION

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/jumpserver/jumpserver /opt/jumpserver \
    && sed -i "s@VERSION = .*@VERSION = \"${VERSION}\"@g" /opt/jumpserver/apps/jumpserver/const.py \
    && chmod +x /opt/jumpserver/entrypoint.sh \
    && rm -f /opt/jumpserver/Dockerfile-ce \
    && rm -rf /opt/jumpserver/.git /opt/jumpserver/.github

WORKDIR /opt/jumpserver

RUN set -ex \
    && echo > /opt/jumpserver/config.yml \
    && cd utils \
    && bash -ixeu build.sh

FROM python:3.11-slim-bookworm as build-core
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

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${BUILD_DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS}  \
    && echo "no" | dpkg-reconfigure dash \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG RUST_VERSION=1.71.1
RUN set -ex \
    && mkdir -p /opt/rust-install \
    && rustUrl="https://static.rust-lang.org/dist" \
    && \
    case "${TARGETARCH}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; \
            ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; \
            ;; \
        mips64le) rustArch='mips64el-unknown-linux-gnuabi64'; \
            ;; \
        ppc64le) rustArch='powerpc64le-unknown-linux-gnu'; \
            ;; \
        riscv64) rustArch='riscv64gc-unknown-linux-gnu'; \
            ;; \
        s390x) rustArch='s390x-unknown-linux-gnu'; \
            ;; \
        loong64) rustArch='loongarch64-unknown-linux-gnu'; \
            rustUrl="https://download.jumpserver.org/rust/dist"; \
            ;; \
        *) echo >&2 "error: unsupported architecture: ${TARGETARCH}"; \
            ;; \
    esac \
    && \
    if [ -n "${rustArch}" ]; then \
        wget -O /opt/rust.tar.gz "${rustUrl}/rust-${RUST_VERSION}-${rustArch}.tar.xz"; \
        tar -xf /opt/rust.tar.gz -C /opt/rust-install --strip-components=1; \
        cd /opt/rust-install && ./install.sh; \
        cd /opt && rm -rf /opt/rust-install /opt/rust.tar.gz; \
    fi

COPY --from=get-core /opt/jumpserver/poetry.lock /opt/jumpserver/pyproject.toml /opt/jumpserver/

WORKDIR /opt/jumpserver

ARG PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

ENV GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1

RUN set -ex \
    && python3 -m venv /opt/py3 \
    && pip install $(grep cryptography pyproject.toml | sed 's/ = /==/g' | sed 's/"//g') \
    && pip install poetry \
    && poetry config virtualenvs.create false \
    && . /opt/py3/bin/activate \
    && poetry install --only=main

FROM python:3.11-slim-bookworm
ARG TARGETARCH
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        freerdp2-dev                  \
        libldap2-dev                  \
        libx11-dev                    \
        libxmlsec1-openssl"

ARG TOOLS="                           \
        ca-certificates               \
        curl                          \
        default-libmysqlclient-dev    \
        default-mysql-client          \
        nginx                         \
        logrotate                     \
        openjdk-17-jre-headless       \
        openssh-client                \
        sshpass                       \
        supervisor                    \
        wget"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && mkdir -p /root/.ssh/ /var/cache/nginx \
    && echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n\tCiphers +aes128-cbc\n\tKexAlgorithms +diffie-hellman-group1-sha1\n\tHostKeyAlgorithms +ssh-rsa" > /root/.ssh/config \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG MONGOSH_VERSION=1.10.6
RUN set -ex \
    && \
    case "${TARGETARCH}" in \
        amd64) \
            wget https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-x64/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh /usr/local/bin/ \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh_crypt_v1.so /usr/local/lib/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-x64* \
            ;; \
        arm64|s390x|ppc64le) \
            wget https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
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
    && wget -O /usr/local/bin/rawkubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl \
    && wget http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && wget https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz -C /opt --strip-components=1 linux-${TARGETARCH}/helm \
    && mv helm /usr/local/bin/rawhelm \
    && chmod 755 /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && chown root:root /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && rm -f /opt/*.tar.gz

ARG WISP_VERSION=v0.1.16
RUN set -ex \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
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
COPY --from=static /opt/download/applets /opt/download/applets

ARG VERSION=v3.10.2
ENV VERSION=${VERSION}
ENV PATH=/opt/py3/bin:$PATH

WORKDIR /opt

RUN set -ex \
    && mkdir -p /opt/koko \
    && wget https://github.com/jumpserver/koko/releases/download/${VERSION}/koko-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf koko-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/koko/ --strip-components=1 \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && mv /opt/koko/helm /usr/local/bin/ \
    && chmod 755 /usr/local/bin/helm /usr/local/bin/kubectl /opt/koko/init-kubectl.sh \
    && chown root:root /usr/local/bin/helm /usr/local/bin/kubectl \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/lion \
    && wget https://github.com/jumpserver/lion-release/releases/download/${VERSION}/lion-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/lion --strip-components=1 \
    && chown -R root:root /opt/lion \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/kael \
    && wget https://github.com/jumpserver/kael/releases/download/${VERSION}/kael-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf kael-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/kael --strip-components=1 \
    && chmod 755 /opt/kael/kael \
    && chown -R root:root /opt/kael \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/chen \
    && wget https://github.com/jumpserver/chen-release/releases/download/${VERSION}/chen-${VERSION}.tar.gz \
    && tar -xf chen-${VERSION}.tar.gz -C /opt/chen --strip-components=1 \
    && chown -R root:root /opt/chen \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/lina \
    && wget https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && chown -R root:root /opt/lina \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/luna \
    && wget https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && chown -R root:root /opt/luna \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && cd /opt/download/applets \
    && wget https://github.com/jumpserver/applets/releases/download/${VERSION}/pip_packages.zip

COPY readme.txt readme.txt
COPY entrypoint.sh .
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /opt/lion/data
VOLUME /opt/kael/data
VOLUME /opt/chen/data

EXPOSE 80 2222
ENTRYPOINT ["./entrypoint.sh"]