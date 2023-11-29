FROM jumpserver/redis:7.0-buster as redis

FROM debian:buster-slim
ARG TARGETARCH
ENV LANG=zh_CN.UTF-8

ARG DEPENDENCIES="                    \
        bash-completion               \
        ca-certificates               \
        curl                          \
        libssl-dev                    \
        locales                       \
        mariadb-client                \
        openssh-client                \
        postgresql-client             \
        vim                           \
        wget"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && echo "zh_CN.UTF-8" | dpkg-reconfigure locales \
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
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/* /usr/local/bin/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-x64* \
            ;; \
        arm64) \
            wget https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/* /usr/local/bin/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}* \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}" \
            ;; \
    esac

COPY --from=redis /usr/local/bin/redis-cli /usr/local/bin/redis-cli

ARG HELM_VERSION=v3.12.1

RUN set -ex \
    && wget https://download.jumpserver.org/public/kubectl-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubectl-linux-${TARGETARCH}.tar.gz \
    && mv kubectl /usr/local/bin/rawkubectl \
    && wget http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && \
    if [ "${TARGETARCH}" == "loong64" ]; then \
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

ARG VERSION=v3.9.3
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

VOLUME /opt/koko/data

EXPOSE 2222 5000

CMD [ "./entrypoint.sh" ]
