FROM debian:buster-slim
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        curl                          \
        git                           \
        net-tools                     \
        unzip                         \
        vim                           \
        locales                       \
        wget"

ARG APT_MIRROR=http://mirrors.ustc.edu.cn

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked,id=kael \
    sed -i "s@http://.*.debian.org@${APT_MIRROR}@g" /etc/apt/sources.list \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && apt-get update \
    && echo "no" | dpkg-reconfigure dash \
    && echo "zh_CN.UTF-8" | dpkg-reconfigure locales \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG WISP_VERSION=v0.1.15
RUN set -ex \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

WORKDIR /opt/kael

ARG VERSION=v3.7.1
ENV VERSION=${VERSION}

RUN set -ex \
    && cd /opt \
    && wget https://github.com/jumpserver/kael/releases/download/${VERSION}/kael-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf kael-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/kael --strip-components=1 \
    && chmod 755 /opt/kael/magnus \
    && chown -R root:root /opt/kael \
    && rm -f /opt/*.tar.gz

COPY kael/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

VOLUME /opt/kael/data

EXPOSE 8083

CMD [ "./entrypoint.sh" ]