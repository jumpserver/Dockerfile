FROM centos:7
WORKDIR /opt
ARG Version=1.5.9
ENV Version=${Version} \
    LC_ALL=zh_CN.utf8

RUN set -ex \
    && yum install -y epel-release wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LC_ALL=zh_CN.utf8" > /etc/locale.conf \
    && yum -y install mariadb-server \
    && yum remove -y wget \
    && yum clean all \
    && rm -rf /var/cache/yum/*

COPY mysql/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
