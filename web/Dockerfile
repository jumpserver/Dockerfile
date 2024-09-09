FROM debian:bookworm-slim AS stage-1
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        curl                          \
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

ARG VERSION=v4.1.0
ENV VERSION=${VERSION}

RUN set -e \
    && mkdir -p /opt/lina /opt/luna \
    && wget --quiet https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && wget --quiet https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && rm -f /opt/*.tar.gz

RUN set -e \
    && wget --quiet https://github.com/jumpserver/docker-web/raw/${VERSION}/prepare.sh \
    && wget --quiet https://github.com/jumpserver/docker-web/raw/${VERSION}/versions.txt \
    && chown root:root prepare.sh versions.txt \
    && chmod 755 /opt/prepare.sh

COPY web/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

FROM nginx:1.25-bookworm
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        logrotate"

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

COPY --from=stage-1 /usr/local/bin /usr/local/bin
COPY --from=stage-1 /opt /opt
COPY web/nginx.conf /etc/nginx/

WORKDIR /opt

ARG VERSION=v4.1.0
ENV VERSION=${VERSION}

VOLUME /opt/download
VOLUME /var/log/nginx

COPY web/entrypoint.sh /docker-entrypoint.d/99-check-core-ready.sh