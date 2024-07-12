FROM redis:7.0-bookworm as stage-1
FROM debian:bookworm-slim as stage-2
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        wget"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

WORKDIR /opt

ARG CHECK_VERSION=v1.0.3
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && mv check /usr/local/bin/ \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz

ARG WISP_VERSION=v0.1.21
RUN set -e \
    && wget --quiet https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

ARG MONGOSH_VERSION=2.2.10
RUN set -e \
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
        wget --quiet https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${ARCH}.tgz \
        && tar -xf mongosh-${MONGOSH_VERSION}-linux-${ARCH}.tgz \
        && chown root:root mongosh-${MONGOSH_VERSION}-linux-${ARCH}/bin/* \
        && mv mongosh-${MONGOSH_VERSION}-linux-${ARCH}/bin/mongosh /usr/local/bin/ \
        && mv mongosh-${MONGOSH_VERSION}-linux-${ARCH}/bin/mongosh_crypt_v1.so /usr/local/lib/ \
        && rm -rf mongosh-${MONGOSH_VERSION}-linux-${ARCH}* \
        ; \
    fi

ARG HELM_VERSION=v3.15.2
ARG KUBECTL_VERSION=v1.30.2
RUN set -e \
    && wget --quiet -O kubectl.tar.gz https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubectl.tar.gz --strip-components=3 -C /opt kubernetes/client/bin/kubectl \
    && mv kubectl /usr/local/bin/rawkubectl \
    && mkdir /opt/kubectl-aliases/ \
    && wget --quiet https://github.com/ahmetb/kubectl-aliases/raw/master/.kubectl_aliases \
    && mv .kubectl_aliases /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && wget --quiet https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz --strip-components=1 linux-${TARGETARCH}/helm \
    && mv helm /usr/local/bin/rawhelm \
    && chmod 755 /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && chown root:root /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && rm -f /opt/*.tar.gz

WORKDIR /opt/koko

ARG VERSION=v3.10.12
ENV VERSION=${VERSION}

RUN set -e \
    && cd /opt \
    && wget --quiet https://github.com/jumpserver/koko/releases/download/${VERSION}/koko-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf koko-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/koko/ --strip-components=1 \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && mv /opt/koko/helm /usr/local/bin/ \
    && chmod 755 /usr/local/bin/helm /usr/local/bin/kubectl /opt/koko/init-kubectl.sh \
    && chown root:root /usr/local/bin/helm /usr/local/bin/kubectl \
    && rm -f /opt/*.tar.gz

FROM debian:bookworm-slim
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        bash-completion               \
        ca-certificates               \
        libssl-dev                    \
        mariadb-client                \
        openssh-client                \
        postgresql-client"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc

COPY --from=stage-1 /usr/local/bin/redis-cli /usr/local/bin/redis-cli
COPY --from=stage-2 /usr/local/bin /usr/local/bin
COPY --from=stage-2 /opt/koko /opt/koko
COPY --from=stage-2 /opt/kubectl-aliases /opt/kubectl-aliases

WORKDIR /opt/koko

ARG VERSION=v3.10.12
ENV VERSION=${VERSION}

VOLUME /opt/koko/data

COPY koko/entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]

EXPOSE 2222 5000

STOPSIGNAL SIGQUIT

CMD [ "wisp" ]
