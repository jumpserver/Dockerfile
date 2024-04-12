FROM redis:7.0-bookworm as redis
FROM jumpserver/guacd:1.5.3-bookworm as guacd
FROM jumpserver/jms_core:v3.10.7
ARG TARGETARCH

ARG TOOLS="                           \
        curl                          \
        default-mysql-client          \
        nginx                         \
        logrotate                     \
        openjdk-17-jre-headless       \
        supervisor                    \
        wget"

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && mkdir -p /var/cache/nginx \
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
    && apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=redis /usr/local/bin/redis-cli /usr/local/bin/redis-cli

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