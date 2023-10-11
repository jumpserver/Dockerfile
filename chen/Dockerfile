FROM jumpserver/openjdk:17-slim-buster as jre-build
FROM debian:buster-slim
ARG TARGETARCH
ENV LANG=zh_CN.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        curl                          \
        locales                       \
        p11-kit                       \
        telnet                        \
        vim                           \
        wget"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash \
    && echo "zh_CN.UTF-8" | dpkg-reconfigure locales \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/local/openjdk-17
ENV PATH $JAVA_HOME/bin:$PATH

COPY --from=jre-build $JAVA_HOME $JAVA_HOME
COPY --from=jre-build /etc/ld.so.conf.d/docker-openjdk.conf /etc/ld.so.conf.d/docker-openjdk.conf
COPY --from=jre-build /etc/ca-certificates/update.d/docker-openjdk /etc/ca-certificates/update.d/docker-openjdk

RUN set -ex \
    && chmod +x /etc/ca-certificates/update.d/docker-openjdk \
    && /etc/ca-certificates/update.d/docker-openjdk \
    && ldconfig \
    && java -Xshare:dump \
    && rm -rf ~/.java \
    && javac --version \
    && java --version

WORKDIR /opt

ARG WISP_VERSION=v0.1.15
RUN set -ex \
    && wget https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

WORKDIR /opt/chen

ARG VERSION=v3.7.2
ENV VERSION=${VERSION}

RUN set -ex \
    && cd /opt \
    && wget https://github.com/jumpserver/chen-release/releases/download/${VERSION}/chen-${VERSION}.tar.gz \
    && tar -xf chen-${VERSION}.tar.gz -C /opt/chen --strip-components=1 \
    && chown -R root:root /opt/chen \
    && rm -f /opt/*.tar.gz

COPY chen/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

VOLUME /opt/chen/data

EXPOSE 8082

CMD [ "./entrypoint.sh" ]
