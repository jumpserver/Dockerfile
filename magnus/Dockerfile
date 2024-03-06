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

ARG WISP_VERSION=v0.1.16
RUN set -ex \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

WORKDIR /opt/magnus

ARG VERSION=v3.10.4
ENV VERSION=${VERSION}

RUN set -ex \
    && cd /opt \
    && wget https://github.com/jumpserver/magnus-release/releases/download/${VERSION}/magnus-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf magnus-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/magnus --strip-components=1 \
    && chmod 755 /opt/magnus/magnus \
    && chown -R root:root /opt/magnus \
    && rm -f /opt/*.tar.gz

COPY magnus/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

FROM debian:bookworm-slim
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates"

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
COPY --from=stage-1 /opt/magnus /opt/magnus

WORKDIR /opt/magnus

ARG VERSION=v3.10.4
ENV VERSION=${VERSION}

VOLUME /opt/magnus/data

EXPOSE 33061 33062 63790

CMD [ "./entrypoint.sh" ]
