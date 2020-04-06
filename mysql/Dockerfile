FROM centos:7
WORKDIR /opt
ARG Version=1.5.7
ENV Version=${Version} \
    LC_ALL=en_US.UTF-8

RUN set -ex \
    && yum install -y epel-release wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum -y install mariadb-server \
    && yum remove -y wget \
    && yum clean all \
    && rm -rf /var/cache/yum/*

COPY mysql/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
