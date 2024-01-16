FROM jumpserver/guacd:1.5.3-buster
ARG TARGETARCH
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        curl                          \
        supervisor                    \
        wget"

USER root

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/lion

ARG VERSION=v3.10.1
ENV VERSION=${VERSION}

RUN set -ex \
    && wget https://github.com/jumpserver/lion-release/releases/download/${VERSION}/lion-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/lion --strip-components=1 \
    && chown -R root:root /opt/lion \
    && rm -f /opt/*.tar.gz

COPY lion/supervisord.conf /etc/supervisor/conf.d/lion.conf

COPY lion/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

VOLUME /opt/lion/data

EXPOSE 8081

CMD ["./entrypoint.sh"]
