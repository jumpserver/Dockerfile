ARG version=dev-ce
FROM jumpserver/koko:${version} AS koko
FROM jumpserver/lion:${version} AS lion
FROM jumpserver/chen:${version} AS chen
FROM jumpserver/web:${version} AS web

FROM jumpserver/core:${version} AS core

ARG TOOLS="                           \
        bash-completion               \
        curl                          \
        vim                           \
        procps                        \
        net-tools                     \
        sudo                          \
        logrotate                     \
        supervisor                    \
        postgresql                    \
        openjdk-17-jre-headless       \
        redis                         \
        wget"

ARG APT_MIRROR=http://mirrors.aliyun.com
RUN sed -i "s@http://.*.debian.org@${APT_MIRROR}@g" /etc/apt/sources.list \
    &&apt-get update \
    && apt-get install -y --no-install-recommends ${TOOLS} \
    && apt-get clean

COPY --from=koko /opt /opt
COPY --from=koko /usr /usr

COPY --from=lion /opt /opt
COPY --from=lion /usr /usr
COPY --from=lion /lib /lib

RUN mkdir -p /lib32 /libx32
COPY --from=lion /lib32 /lib32
COPY --from=lion /libx32 /libx32

COPY --from=chen /opt /opt
COPY --from=chen /usr /usr
COPY --from=chen /etc/alternatives /etc/alternatives

COPY --from=web /opt /opt
COPY --from=web /usr /usr
COPY --from=web /etc/nginx /etc/nginx
COPY --from=web /docker-entrypoint.d /docker-entrypoint.d
COPY --from=web /docker-entrypoint.sh /opt/web/entrypoint.sh
RUN useradd nginx \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx 

COPY supervisord.conf /etc/supervisor/conf.d/

FROM debian:bullseye-slim

COPY --from=core / /

VOLUME /opt/data
VOLUME /opt/download
VOLUME /var/log/nginx

EXPOSE 80 2222
ENV LC_ALL=C.UTF-8

WORKDIR /opt
COPY entrypoint.sh .
COPY service.sh .
ENTRYPOINT ["./entrypoint.sh"]
