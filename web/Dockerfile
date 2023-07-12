FROM nginx:1.24
ARG TARGETARCH
ENV LANG=zh_CN.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        curl                          \
        locales                       \
        logrotate                     \
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

WORKDIR /opt/download/public

ARG Client_VERSION=v1.1.8
ARG MRD_VERSION=10.6.7
ARG VIDEO_PLAYER_VERSION=0.1.5

RUN set -ex \
    && wget -qO  JumpServer-Client-Installer-x86_64.msi https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-x86_64.msi \
    && wget -qO  JumpServer-Client-Installer-amd64.dmg https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-amd64.dmg \
    && wget -qO  JumpServer-Client-Installer-arm64.dmg https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-arm64.dmg \
    && wget -qO  JumpServer-Client-Installer-amd64.run https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-amd64.run \
    && wget -qO  JumpServer-Client-Installer-arm64.run https://download.jumpserver.org/public/JumpServer-Client-Installer-${Client_VERSION}-arm64.run \
    && wget -qO  JumpServer-Video-Player.dmg https://download.jumpserver.org/public/JumpServer.Video.Player-${VIDEO_PLAYER_VERSION}.dmg \
    && wget -qO  JumpServer-Video-Player.exe https://download.jumpserver.org/public/JumpServer.Video.Player.Setup.${VIDEO_PLAYER_VERSION}.exe \
    && wget -qO  OpenSSH-Win64.msi https://download.jumpserver.org/public/OpenSSH-Win64.msi \
    && wget -q https://download.jumpserver.org/public/Microsoft_Remote_Desktop_${MRD_VERSION}_installer.pkg

WORKDIR /opt/download/applets

ARG TINKER_VERSION=v0.0.9
ARG PYTHON_VERSION=3.10.8
ARG CHROMIUM_VERSION=1100786
ARG DBEAVER_VERSION=22.3.4

RUN set -ex \
    && wget -qO chromedriver_win32.zip https://download.jumpserver.org/chromium-browser-snapshots/Win_x64/${CHROMIUM_VERSION}/Win_x64_${CHROMIUM_VERSION}_chromedriver_win32.zip \
    && wget -qO chrome-win.zip https://download.jumpserver.org/chromium-browser-snapshots/Win_x64/${CHROMIUM_VERSION}/Win_x64_${CHROMIUM_VERSION}_chrome-win.zip \
    && wget -qO Tinker_Installer.exe https://download.jumpserver.org/public/Tinker_Installer_${TINKER_VERSION}.exe \
    && wget -qO dbeaver-patch.msi https://download.jumpserver.org/public/dbeaver-patch-${DBEAVER_VERSION}-x86_64-setup.msi \
    && wget -q https://download.jumpserver.org/public/dbeaver-ce-${DBEAVER_VERSION}-x86_64-setup.exe \
    && wget -q https://download.jumpserver.org/public/python-${PYTHON_VERSION}-amd64.exe

WORKDIR /opt

ARG VERSION=v3.4.3
ENV VERSION=${VERSION}

RUN set -ex \
    && mkdir -p /opt/lina /opt/luna \
    && wget https://github.com/jumpserver/lina/releases/download/${VERSION}/lina-${VERSION}.tar.gz \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && wget https://github.com/jumpserver/luna/releases/download/${VERSION}/luna-${VERSION}.tar.gz \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && rm -f /opt/*.tar.gz

COPY web/nginx.conf /etc/nginx/
COPY web/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD [ "./entrypoint.sh" ]
