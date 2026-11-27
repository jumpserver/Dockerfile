ARG version=v5.3.0-ce
FROM jumpserver/koko:${version} AS koko
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
        postgresql                    \
        redis                         \
        wget"

ARG APT_MIRROR=http://deb.debian.org
# Core may use a private mirror; replace URI hosts while preserving repository paths.
RUN sed -i -E "/^URIs:/s@https?://[^/[:space:]]+@${APT_MIRROR%/}@g" /etc/apt/sources.list.d/debian.sources \
    && apt-get update -o APT::Update::Error-Mode=any \
    && apt-get install -y --no-install-recommends ${TOOLS} \
    && apt-get clean

# Koko includes guacd and its runtime libraries.
COPY --from=koko /opt /opt
COPY --from=koko /usr /usr

# Use the overlay and component service scripts from the very same KoKo image.
COPY --from=koko /init /init
COPY --from=koko /package /package
COPY --from=koko /command /command
COPY --from=koko /etc/s6-overlay /etc/s6-overlay
COPY --from=koko /etc/services.d /etc/services.d
COPY --from=koko /etc/cont-init.d /etc/cont-init.d
# This init waits for Core. Run it as a dependent s6-rc oneshot.
RUN mv /etc/cont-init.d/10-koko-init /opt/koko/container-init

COPY --from=web /opt /opt
COPY --from=web /usr /usr
COPY --from=web /etc/nginx /etc/nginx
COPY --from=web /docker-entrypoint.d /docker-entrypoint.d
COPY --from=web /docker-entrypoint.sh /opt/web/entrypoint.sh
RUN useradd nginx \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx

FROM debian:trixie-slim

COPY --from=core / /
# Redis enters its data directory before dropping privileges (the volume root can be 0700).
RUN sed -i 's|^dir /var/lib/redis$|dir .|' /etc/redis/redis.conf
COPY s6/ /etc/s6-overlay/s6-rc.d/
COPY web-run /etc/services.d/web/run

VOLUME /opt/data
VOLUME /opt/download

EXPOSE 80 2222
ENV LC_ALL=C.UTF-8
ENV ANSIBLE_DOCKER_ENABLED=false
ENV KAEL_ENABLED=1
ENV PLATFORM_GATEWAY_ENABLED=true
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
# Allow KoKo to flush sessions while Core and storage are still available.
ENV S6_SERVICES_GRACETIME=55000
ENV PATH=/opt/py3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /opt
COPY entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
