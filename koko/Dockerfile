FROM redis:7.0-bookworm AS stage-1
FROM debian:bookworm-slim AS stage-2
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
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ check \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f /opt/*.tar.gz

ARG WISP_VERSION=v0.1.22
RUN set -e \
    && wget --quiet https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

ARG USQL_VERSION=v0.0.1
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/usql/releases/download/${USQL_VERSION}/usql-${USQL_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf usql-${USQL_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/usql \
    && chmod 755 /usr/local/bin/usql \
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

ARG VERSION=v4.1.0
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
        ca-certificates"

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
COPY --from=stage-2 /usr/local/lib /usr/local/lib
COPY --from=stage-2 /opt/koko /opt/koko
COPY --from=stage-2 /opt/kubectl-aliases /opt/kubectl-aliases

WORKDIR /opt/koko

ARG VERSION=v4.1.0
ENV VERSION=${VERSION}

VOLUME /opt/koko/data

COPY koko/entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]

EXPOSE 2222 5000

STOPSIGNAL SIGQUIT

CMD [ "wisp" ]
