FROM jumpserver/redis:6.2 as redis
FROM jumpserver/guacd:1.5.2 as guacd

FROM jumpserver/python:3.9-slim-buster
ARG TARGETARCH
ENV LANG=zh_CN.UTF-8

ARG BUILD_DEPENDENCIES="              \
        g++                           \
        make                          \
        pkg-config"

ARG DEPENDENCIES="                    \
        freetds-dev                   \
        libpq-dev                     \
        libffi-dev                    \
        libjpeg-dev                   \
        libldap2-dev                  \
        libsasl2-dev                  \
        libssl-dev                    \
        libxml2-dev                   \
        libxmlsec1-dev                \
        libxmlsec1-openssl            \
        freerdp2-dev                  \
        libaio-dev"

ARG TOOLS="                           \
        ca-certificates               \
        cron                          \
        curl                          \
        default-libmysqlclient-dev    \
        default-mysql-client          \
        git                           \
        git-lfs                       \
        iputils-ping                  \
        locales                       \
        logrotate                     \
        netcat                        \
        openssh-client                \
        procps                        \
        sshpass                       \
        supervisor                    \
        telnet                        \
        unzip                         \
        vim                           \
        wget"

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${BUILD_DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && mkdir -p /root/.ssh/ \
    && echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n\tCiphers +aes128-cbc\n\tKexAlgorithms +diffie-hellman-group1-sha1\n\tHostKeyAlgorithms +ssh-rsa" > /root/.ssh/config \
    && echo "set mouse-=a\nset ts=4\nset expandtab" > ~/.vimrc \
    && echo "no" | dpkg-reconfigure dash \
    && echo "zh_CN.UTF-8" | dpkg-reconfigure locales \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ARG MONGOSH_VERSION=1.9.1
RUN set -ex \
    && \
    case "${TARGETARCH}" in \
        amd64) \
            wget -q https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-x64.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-x64/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh /usr/local/bin/ \
            && mv mongosh-${MONGOSH_VERSION}-linux-x64/bin/mongosh_crypt_v1.so /usr/local/lib/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-x64* \
            ;; \
        arm64) \
            wget -q https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && tar -xf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}.tgz \
            && chown root:root mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/* \
            && mv mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/mongosh /usr/local/bin/ \
            && mv mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}/bin/mongosh_crypt_v1.so /usr/local/lib/ \
            && rm -rf mongosh-${MONGOSH_VERSION}-linux-${TARGETARCH}* \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}" \
            ;; \
    esac

ARG HELM_VERSION=v3.12.2
RUN set -ex \
    && wget -q https://download.jumpserver.org/public/kubectl-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubectl-linux-${TARGETARCH}.tar.gz \
    && mv kubectl /usr/local/bin/rawkubectl \
    && wget -q http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && \
    if [ "${TARGETARCH}" == "loong64" ]; then \
        wget -q https://github.com/wojiushixiaobai/helm-loongarch64/releases/download/${HELM_VERSION}/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz; \
    else \
        wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz; \
    fi \
    && tar -xf helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz -C /opt --strip-components=1 linux-${TARGETARCH}/helm \
    && mv helm /usr/local/bin/rawhelm \
    && chmod 755 /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && chown root:root /usr/local/bin/rawhelm /usr/local/bin/rawkubectl \
    && rm -f /opt/*.tar.gz

ARG WISP_VERSION=v0.1.10
RUN set -ex \
    && wget -q https://github.com/jumpserver/wisp/releases/download/${WISP_VERSION}/wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf wisp-${WISP_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ --strip-components=1 \
    && chown root:root /usr/local/bin/wisp \
    && chmod 755 /usr/local/bin/wisp \
    && rm -f /opt/*.tar.gz

ARG Client_VERSION=v1.1.8
ARG MRD_VERSION=10.6.7
ARG VIDEO_PLAYER_VERSION=0.1.9
ARG OPENSSH_VERSION=v9.2.0.0
RUN set -ex \
    && mkdir -p /opt/download/public \
    && cd /opt/download/public \
    && wget -qO  JumpServer-Client-Installer-x86_64.msi https://github.com/jumpserver/clients/releases/download/${Client_VERSION}/JumpServer-Client-Installer-${Client_VERSION}-x86_64.msi \
    && wget -qO  JumpServer-Client-Installer-amd64.dmg https://github.com/jumpserver/clients/releases/download/${Client_VERSION}/JumpServer-Client-Installer-${Client_VERSION}-amd64.dmg \
    && wget -qO  JumpServer-Client-Installer-arm64.dmg https://github.com/jumpserver/clients/releases/download/${Client_VERSION}/JumpServer-Client-Installer-${Client_VERSION}-arm64.dmg \
    && wget -qO  JumpServer-Client-Installer-amd64.run https://github.com/jumpserver/clients/releases/download/${Client_VERSION}/JumpServer-Client-Installer-${Client_VERSION}-amd64.run \
    && wget -qO  JumpServer-Client-Installer-arm64.run https://github.com/jumpserver/clients/releases/download/${Client_VERSION}/JumpServer-Client-Installer-${Client_VERSION}-arm64.run \
    && wget -qO  JumpServer-Video-Player.dmg https://github.com/jumpserver/VideoPlayer/releases/download/v0.1.9/JumpServer.Video.Player-${VIDEO_PLAYER_VERSION}.dmg \
    && wget -qO  JumpServer-Video-Player.exe https://github.com/jumpserver/VideoPlayer/releases/download/v0.1.9/JumpServer.Video.Player.Setup.${VIDEO_PLAYER_VERSION}.exe \
    && wget -qO  OpenSSH-Win64.msi https://github.com/PowerShell/Win32-OpenSSH/releases/download/${OPENSSH_VERSION}p1-Beta/OpenSSH-Win64-${OPENSSH_VERSION}.msi \
    && wget -q https://download.jumpserver.org/public/Microsoft_Remote_Desktop_${MRD_VERSION}_installer.pkg

ARG TINKER_VERSION=v0.1.0
ARG PYTHON_VERSION=3.10.11
ARG CHROME_VERSION=114.0.5735.134
ARG DBEAVER_VERSION=22.3.4
RUN set -ex \
    && mkdir -p /opt/download/applets \
    && cd /opt/download/applets \
    && wget -qO Tinker_Installer.exe https://download.jumpserver.org/public/Tinker_Installer_${TINKER_VERSION}.exe \
    && wget -qO dbeaver-patch.msi https://download.jumpserver.org/public/dbeaver-patch-${DBEAVER_VERSION}-x86_64-setup.msi \
    && wget -q https://github.com/wojiushixiaobai/Chrome-Portable-Win64/releases/download/${CHROME_VERSION}/chromedriver_win32.zip \
    && wget -q https://github.com/wojiushixiaobai/Chrome-Portable-Win64/releases/download/${CHROME_VERSION}/chrome-win.zip \
    && wget -q https://download.jumpserver.org/public/dbeaver-ce-${DBEAVER_VERSION}-x86_64-setup.exe \
    && wget -q https://download.jumpserver.org/public/python-${PYTHON_VERSION}-amd64.exe

ARG PREFIX_DIR=/opt/guacamole
ENV LD_LIBRARY_PATH=${PREFIX_DIR}/lib
ARG RUNTIME_DEPENDENCIES="            \
        fonts-dejavu                  \
        fonts-liberation              \
        ghostscript                   \
        netcat-openbsd                \
        xfonts-terminus"

COPY --from=guacd ${PREFIX_DIR} ${PREFIX_DIR}

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends $RUNTIME_DEPENDENCIES \
    && apt-get install -y --no-install-recommends $(cat "${PREFIX_DIR}"/DEPENDENCIES) \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=redis /usr/local/bin/redis-cli /usr/local/bin/redis-cli

ARG VERSION=v3.4.3
ENV VERSION=${VERSION}

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/jumpserver/jumpserver /opt/jumpserver \
    && sed -i "s@VERSION = .*@VERSION = \"${VERSION}\"@g" /opt/jumpserver/apps/jumpserver/const.py \
    && chmod +x /opt/jumpserver/entrypoint.sh \
    && rm -rf /opt/jumpserver/.git /opt/jumpserver/.github

RUN set -ex \
    && cd /opt/jumpserver \
    && echo > /opt/jumpserver/config.yml \
    && \
    if [ "${TARGETARCH}" == "loong64" ]; then \
        pip install https://download.jumpserver.org/pypi/simple/cryptography/cryptography-38.0.4-cp39-cp39-linux_loongarch64.whl; \
        pip install https://download.jumpserver.org/pypi/simple/greenlet/greenlet-1.1.2-cp39-cp39-linux_loongarch64.whl; \
        pip install https://download.jumpserver.org/pypi/simple/PyNaCl/PyNaCl-1.5.0-cp39-cp39-linux_loongarch64.whl; \
        pip install https://download.jumpserver.org/pypi/simple/grpcio/grpcio-1.54.2-cp39-cp39-linux_loongarch64.whl; \
    fi \
    && pip install -r requirements/requirements.txt --use-deprecated=legacy-resolver \
    && rm -rf /root/.cache/pip

RUN set -ex \
    && mkdir -p /opt/koko \
    && wget -q https://github.com/jumpserver/koko/releases/download/${VERSION}/koko-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf koko-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/koko/ --strip-components=1 \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && mv /opt/koko/helm /usr/local/bin/ \
    && chmod 755 /usr/local/bin/helm /usr/local/bin/kubectl /opt/koko/init-kubectl.sh \
    && chown root:root /usr/local/bin/helm /usr/local/bin/kubectl \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/lion \
    && wget -q https://github.com/jumpserver/lion-release/releases/download/${VERSION}/lion-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf lion-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/lion --strip-components=1 \
    && chown -R root:root /opt/lion \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/magnus \
    && wget -q https://github.com/jumpserver/magnus-release/releases/download/${VERSION}/magnus-${VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf magnus-${VERSION}-linux-${TARGETARCH}.tar.gz -C /opt/magnus --strip-components=1 \
    && chmod 755 /opt/magnus/magnus \
    && chown -R root:root /opt/magnus \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/lina \
    && wget -q https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && chown -R root:root /opt/lina \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && mkdir -p /opt/luna \
    && wget -q https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && chown -R root:root /opt/luna \
    && rm -f /opt/*.tar.gz

RUN set -ex \
    && cd /opt/download/applets \
    && wget -q https://github.com/jumpserver/applets/releases/download/${VERSION}/pip_packages.zip

RUN set -ex \
    && apt-get update \
    && apt-get -y install --no-install-recommends gnupg1 \
    && dpkgArch="$(dpkg --print-architecture)" \
    && case "$dpkgArch" in \
        amd64|arm64) \
            echo "deb https://nginx.org/packages/debian/ buster nginx" >> /etc/apt/sources.list.d/nginx.list \
            && wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add - \
            ;; \
        *) \
            echo "Unsupported architecture: ${dpkgArch}" \
            ;; \
    esac \
    && apt-get -y install --no-install-recommends nginx \
    && mkdir -p /var/cache/nginx \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY readme.txt readme.txt
COPY entrypoint.sh .
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /opt/lion/data
VOLUME /opt/magnus/data

EXPOSE 80 2222
ENTRYPOINT ["./entrypoint.sh"]