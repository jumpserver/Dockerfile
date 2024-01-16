FROM jumpserver/openjdk:17-slim-bullseye as stage-1
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
    && wget https://github.com/jumpserver-dev/healthch/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && mv check /usr/local/bin/ \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz

ARG WISP_VERSION=v0.1.16
RUN set -ex \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

WORKDIR /opt/chen

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

RUN set -ex \
    && cd /opt \
    && wget https://github.com/jumpserver/chen-release/releases/download/${VERSION}/chen-${VERSION}.tar.gz \
    && tar -xf chen-${VERSION}.tar.gz -C /opt/chen --strip-components=1 \
    && chown -R root:root /opt/chen \
    && rm -f /opt/*.tar.gz

COPY chen/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

FROM debian:bullseye-slim
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        p11-kit"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/local/openjdk-17
ENV PATH $JAVA_HOME/bin:$PATH

COPY --from=stage-1 $JAVA_HOME $JAVA_HOME
COPY --from=stage-1 /etc/ld.so.conf.d/docker-openjdk.conf /etc/ld.so.conf.d/docker-openjdk.conf
COPY --from=stage-1 /etc/ca-certificates/update.d/docker-openjdk /etc/ca-certificates/update.d/docker-openjdk

RUN set -ex \
    && chmod +x /etc/ca-certificates/update.d/docker-openjdk \
    && /etc/ca-certificates/update.d/docker-openjdk \
    && ldconfig \
    && java -Xshare:dump \
    && rm -rf ~/.java \
    && javac --version \
    && java --version

COPY --from=stage-2 /usr/local/bin /usr/local/bin
COPY --from=stage-2 /opt/chen /opt/chen

WORKDIR /opt/chen

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

VOLUME /opt/chen/data

EXPOSE 8082

CMD [ "./entrypoint.sh" ]
