ARG version=v5.0.0-ce
FROM jumpserver/koko:${version} AS koko
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
        openjdk-21-jre-headless       \
        redis                         \
        wget"

ARG APT_MIRROR=http://deb.debian.org
RUN sed -i "s@http://.*.debian.org@${APT_MIRROR}@g" /etc/apt/sources.list.d/debian.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${TOOLS} \
    && apt-get clean

# Koko includes guacd and its runtime libraries.
COPY --from=koko /opt /opt
COPY --from=koko /usr /usr

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

FROM debian:trixie-slim

COPY --from=core / /

VOLUME /opt/data
VOLUME /opt/download
VOLUME /var/log/nginx

EXPOSE 80 2222
ENV LC_ALL=C.UTF-8
ENV ANSIBLE_DOCKER_ENABLED=false

WORKDIR /opt
COPY entrypoint.sh .
COPY service.sh .
ENTRYPOINT ["./entrypoint.sh"]
