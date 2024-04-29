FROM debian:bookworm-slim as stage-1
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        wget"

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG CHECK_VERSION=v1.0.2
RUN set -ex \
    && wget https://github.com/jumpserver-dev/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && mv check /usr/local/bin/ \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz

ARG VERSION=v3.10.9
ENV VERSION=${VERSION}

RUN set -ex \
    && mkdir -p /opt/lina /opt/luna \
    && wget https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && wget https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && rm -f /opt/*.tar.gz

COPY web/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

FROM nginx:1.25-bookworm
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        logrotate                     \
        wget"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=stage-1 /usr/local/bin /usr/local/bin
COPY --from=stage-1 /opt /opt
COPY web/nginx.conf /etc/nginx/

WORKDIR /opt

RUN set -ex \
    && STATIC_VERSION=$(curl -sSL https://github.com/jumpserver/web-static/raw/v3/VERSION) \
    && wget -O /opt/prepare.sh https://github.com/jumpserver/web-static/raw/${STATIC_VERSION}/prepare.sh \
    && chown root:root /opt/prepare.sh \
    && chmod 755 /opt/prepare.sh

ARG VERSION=v3.10.9
ENV VERSION=${VERSION}

VOLUME /opt/download
VOLUME /var/log/nginx

CMD [ "./entrypoint.sh" ]
