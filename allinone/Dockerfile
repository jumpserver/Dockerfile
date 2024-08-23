ARG version=dev
FROM jumpserver/koko:${version} AS koko

FROM jumpserver/core:${version}

ARG TOOLS="                           \
        bash-completion               \
        curl                          \
        default-mysql-client          \
        nginx                         \
        logrotate                     \
        openjdk-17-jre-headless       \
        supervisor                    \
        wget"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ${TOOLS} \
    && apt-get clean

COPY --from=koko /opt /opt
COPY --from=koko /usr/local/bin /usr/local/bin


VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data

EXPOSE 80 2222

ENTRYPOINT ["./entrypoint.sh"]
