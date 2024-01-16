FROM redis:7.0-bullseye as stage-1
FROM debian:bullseye-slim as stage-2
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        wget"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -ex \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES}

WORKDIR /opt

ARG CHECK_VERSION=v1.0.1
RUN set -ex \
    && wget https://github.com/wojiushixiaobai/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && mv check /usr/local/bin/ \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz

ARG MONGOSH_VERSION=2.1.1
RUN set -ex \
    && \
    case "${TARGETARCH}" in \
        'amd64') \
            ARCH=x64; \
            ;; \
        'arm64') \
            ARCH=arm64; \
            ;; \
        's390x') \
            ARCH=s390x; \
            ;; \
        'ppc64le') \
            ARCH=ppc64le; \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}"; \
            ;; \
    esac \
    && \
    if [ -n "${ARCH}" ]; then \
        wget https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${ARCH}.tgz \
        && tar -xf mongosh-${MONGOSH_VERSION}-linux-${ARCH}.tgz \
        && chown root:root mongosh-${MONGOSH_VERSION}-linux-${ARCH}/bin/* \
        && mv mongosh-${MONGOSH_VERSION}-linux-${ARCH}/bin/mongosh /usr/local/bin/ \
        && mv mongosh-${MONGOSH_VERSION}-linux-${ARCH}/bin/mongosh_crypt_v1.so /usr/local/lib/ \
        && rm -rf mongosh-${MONGOSH_VERSION}-linux-${ARCH}* \
        ; \
    fi

ARG HELM_VERSION=v3.13.3
ARG KUBECTL_VERSION=v1.29.0
RUN set -ex \
    && wget -O kubectl.tar.gz https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubectl.tar.gz --strip-components=3 -C /opt kubernetes/client/bin/kubectl \
    && mv kubectl /usr/local/bin/rawkubectl \
    && mkdir /opt/kubectl-aliases/ \
    && wget https://github.com/ahmetb/kubectl-aliases/raw/master/.kubectl_aliases \
    && mv .kubectl_aliases /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && \
    if [ "${TARGETARCH}" = "loong64" ]; then \
        wget https://github.com/wojiushixiaobai/helm-loongarch64/releases/download/${HELM_VERSION}/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz; \
    else \
        wget https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz; \
    fi \
    && tar -xf helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz --strip-components=1 linux-${TARGETARCH}/helm \
    && mv helm /usr/local/bin/rawhelm \
    && chmod 755 /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && chown root:root /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && rm -f /opt/*.tar.gz

WORKDIR /opt/koko

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

RUN set -ex \
    && cd /opt \
    && wget https://github.com/jumpserver/koko/releases/download/${VERSION}/koko-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf koko-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/koko/ --strip-components=1 \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && mv /opt/koko/helm /usr/local/bin/ \
    && chmod 755 /usr/local/bin/helm /usr/local/bin/kubectl /opt/koko/init-kubectl.sh \
    && chown root:root /usr/local/bin/helm /usr/local/bin/kubectl \
    && rm -f /opt/*.tar.gz

COPY koko/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

FROM debian:bullseye-slim
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        libssl-dev                    \
        mariadb-client                \
        openssh-client                \
        postgresql-client"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=stage-1 /usr/local/bin/redis-cli /usr/local/bin/redis-cli
COPY --from=stage-2 /usr/local/bin /usr/local/bin
COPY --from=stage-2 /opt/koko /opt/koko
COPY --from=stage-2 /opt/kubectl-aliases /opt/kubectl-aliases

WORKDIR /opt/koko

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

VOLUME /opt/koko/data

EXPOSE 2222 5000

CMD [ "./entrypoint.sh" ]
