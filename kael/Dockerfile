FROM debian:bullseye-slim as stage-1
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

ARG WISP_VERSION=v0.1.16
RUN set -ex \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

WORKDIR /opt/kael

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

RUN set -ex \
    && cd /opt \
    && wget https://github.com/jumpserver/kael/releases/download/${VERSION}/kael-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf kael-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/kael --strip-components=1 \
    && chmod 755 /opt/kael/kael \
    && chown -R root:root /opt/kael \
    && rm -f /opt/*.tar.gz

COPY kael/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

FROM debian:bullseye-slim
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && apt-get update \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=stage-1 /usr/local/bin /usr/local/bin
COPY --from=stage-1 /opt/kael /opt/kael

WORKDIR /opt/kael

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

VOLUME /opt/kael/data

EXPOSE 8083

CMD [ "./entrypoint.sh" ]