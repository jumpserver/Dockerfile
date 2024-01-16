FROM jumpserver/web-static:v1.0.5 as stage-1
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

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

RUN set -ex \
    && mkdir -p /opt/lina /opt/luna \
    && wget https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && wget https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && mkdir -p /opt/download/applets \
    && wget -O /opt/download/applets/pip_packages.zip https://github.com/jumpserver/applets/releases/download/${VERSION}/pip_packages.zip \
    && rm -f /opt/*.tar.gz

COPY web/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

FROM nginx:1.24-bullseye
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        logrotate"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=stage-1 /opt/download /opt/download
COPY --from=stage-2 /usr/local/bin /usr/local/bin
COPY --from=stage-2 /opt /opt
COPY web/nginx.conf /etc/nginx/

WORKDIR /opt

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

VOLUME /var/log/nginx

CMD [ "./entrypoint.sh" ]
