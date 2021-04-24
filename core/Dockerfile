FROM centos:8
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.9.2
ENV Version=${Version}

RUN set -ex \
    && yum install -y epel-release wget dnf-plugins-core glibc-langpack-en \
    && yum config-manager --set-enable powertools \
    && yum config-manager --enable devel \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum -y install gcc nc libffi-devel libxml2 libxslt-devel \
    && yum -y install python36 python36-devel \
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && chown -R root:root jumpserver \
    && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt | sed "s/mysql.*//g") \
    && python3.6 -m venv /opt/py3 \
    && source /opt/py3/bin/activate \
    && pip install --upgrade pip \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && yum clean all \
    && yum config-manager --disable devel \
    && rm -rf /var/cache/yum/* \
    && rm -rf /opt/*.tar.gz \
    && rm -rf /var/cache/yum* \
    && rm -rf ~/.cache/pip

COPY core/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
