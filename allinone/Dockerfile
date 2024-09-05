ARG version=dev-ce
FROM jumpserver/koko:${version} AS koko
FROM jumpserver/lion:${version} AS lion
FROM jumpserver/chen:${version} AS chen
FROM jumpserver/web:${version} AS web

FROM jumpserver/core:${version}

ARG TOOLS="                           \
        bash-completion               \
        curl                          \
        vim                           \
        procps                        \
        sudo                          \
        logrotate                     \
        supervisor                    \
        postgresql                    \
        openjdk-17-jre-headless       \
        redis                         \
        wget"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ${TOOLS} \
    && apt-get clean

COPY --from=koko /opt /opt
COPY --from=koko /usr /usr

COPY --from=lion /opt /opt
COPY --from=lion /usr /usr

COPY --from=chen /opt /opt
COPY --from=chen /usr /usr
COPY --from=chen /etc/alternatives /etc/alternatives

COPY --from=web /opt /opt
COPY --from=web /usr /usr
COPY --from=web /etc/nginx /etc/nginx
COPY --from=web /docker-entrypoint.d /docker-entrypoint.d

COPY supervisord.conf /etc/supervisor/conf.d/

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data

EXPOSE 80 2222
ENV LC_ALL=C.UTF-8

WORKDIR /opt
COPY entrypoint.sh .
COPY start_db.sh .
ENTRYPOINT ["./entrypoint.sh"]
