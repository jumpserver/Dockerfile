FROM python:3.11-slim-bookworm AS stage-1
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        git                           \
        wget"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

WORKDIR /opt

ARG CHECK_VERSION=v1.0.3
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ check \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f /opt/*.tar.gz

ARG VERSION=v3.10.11
ENV VERSION=$VERSION

RUN set -e \
    && git clone -b ${VERSION} --depth=1 https://github.com/jumpserver/jumpserver /opt/jumpserver

WORKDIR /opt/jumpserver

RUN set -e \
    && echo > /opt/jumpserver/config.yml \
    && \
    if [ -n "${VERSION}" ]; then \
        sed -i "s@VERSION = .*@VERSION = '${VERSION}'@g" apps/jumpserver/const.py; \
    fi \
    && chmod +x /opt/jumpserver/entrypoint.sh \
    && rm -rf /opt/jumpserver/.git /opt/jumpserver/.github

FROM python:3.11-slim-bookwormAS stage-2
ARG TARGETARCH

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
        curl                          \
        default-libmysqlclient-dev    \
        default-mysql-client          \
        git                           \
        git-lfs                       \
        unzip                         \
        xz-utils                      \
        wget"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${BUILD_DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && echo "no" | dpkg-reconfigure dash

WORKDIR /opt

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1

RUN --mount=type=cache,target=/root/.cache,sharing=locked \
    set -e \
    && pip install poetry

WORKDIR /opt/jumpserver

COPY --from=stage-1 /opt/jumpserver/poetry.lock /opt/jumpserver/pyproject.toml /opt/jumpserver/

RUN --mount=type=cache,target=/root/.cache,sharing=locked \
    set -e \
    && python3 -m venv /opt/py3 \
    && . /opt/py3/bin/activate \
    && poetry install --only=main

COPY --from=stage-1 /opt/jumpserver /opt/jumpserver

RUN set -e \
    && export SECRET_KEY=$(head -c100 < /dev/urandom | base64 | tr -dc A-Za-z0-9 | head -c 48) \
    && . /opt/py3/bin/activate \
    && cd apps \
    && python manage.py compilemessages

FROM python:3.11-slim-bookworm
ENV LANG=en_US.UTF-8 \
    PATH=/opt/py3/bin:$PATH

ARG DEPENDENCIES="                    \
        libldap2-dev                  \
        libpq-dev                     \
        libx11-dev                    \
        libxmlsec1-openssl"

ARG TOOLS="                           \
        bubblewrap                    \
        ca-certificates               \
        default-libmysqlclient-dev    \
        openssh-client                \
        sshpass"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && apt-get -y install --no-install-recommends ${TOOLS} \
    && mkdir -p /root/.ssh/ \
    && echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n\tCiphers +aes128-cbc\n\tKexAlgorithms +diffie-hellman-group1-sha1\n\tHostKeyAlgorithms +ssh-rsa" > /root/.ssh/config \
    && echo "no" | dpkg-reconfigure dash \
    && sed -i "s@# export @export @g" ~/.bashrc \
    && sed -i "s@# alias @alias @g" ~/.bashrc

COPY --from=stage-2 /opt /opt
COPY --from=stage-1 /usr/local/bin /usr/local/bin
COPY --from=stage-1 /opt/jumpserver/apps/libs/ansible/ansible.cfg /etc/ansible/

WORKDIR /opt/jumpserver

ARG VERSION=v3.10.11
ENV VERSION=${VERSION}

VOLUME /opt/jumpserver/data

COPY core/entrypoint.sh /opt/entrypoint.sh
ENTRYPOINT ["/opt/entrypoint.sh"]

EXPOSE 8080

STOPSIGNAL SIGQUIT

CMD ["start", "all"]