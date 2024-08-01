FROM redis:7.0-bookworm AS redis
FROM jumpserver/guacd:1.5.5-bookworm AS guacd
FROM jumpserver/jms_core:v4.0.2
ARG TARGETARCH

ARG TOOLS="                           \
        bash-completion               \
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

ARG WISP_VERSION=v0.1.22
RUN set -ex \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

ARG MONGOSH_VERSION=2.2.12
RUN set -e \
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
        arm64|ppc64le|s390x) \
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

ARG HELM_VERSION=v3.15.2
ARG KUBECTL_VERSION=v1.30.2
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

ARG PREFIX_DIR=/opt/guacamole
ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib
ARG RUNTIME_DEPENDENCIES="            \
        fonts-dejavu                  \
        fonts-liberation              \
        ghostscript                   \
        xfonts-terminus"

COPY --from=guacd ${PREFIX_DIR} ${PREFIX_DIR}

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=redis /usr/local/bin/redis-cli /usr/local/bin/redis-cli

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
    && wget https://github.com/jumpserver/lion/releases/download/${VERSION}/lion-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/lion --strip-components=1 \
    && chown -R root:root /opt/lion \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/chen \
    && wget https://github.com/jumpserver/chen/releases/download/${VERSION}/chen-${VERSION}.tar.gz \
    && tar -xf chen-${VERSION}.tar.gz -C /opt/chen --strip-components=1 \
    && chown -R root:root /opt/chen \
    && sed -i 's/http:\/\/core/http:\/\/127.0.0.1/g' /opt/chen/config/application.yml
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && STATIC_VERSION=$(curl -sSL https://github.com/jumpserver/web-static/raw/v3/VERSION) \
    && wget -O /opt/prepare.sh https://github.com/jumpserver/web-static/raw/${STATIC_VERSION}/prepare.sh \
    && chown root:root /opt/prepare.sh \
    && chmod 755 /opt/prepare.sh

COPY readme.txt readme.txt
COPY entrypoint.sh .
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /opt/lion/data
VOLUME /opt/chen/data
VOLUME /opt/download
VOLUME /var/log/nginx

EXPOSE 80 2222

ENTRYPOINT ["./entrypoint.sh"]
