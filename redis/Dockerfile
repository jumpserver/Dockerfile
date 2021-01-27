FROM centos:7
WORKDIR /opt
ARG Version=v2.6.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && yum install -y epel-release \
    && yum -y install epel-release https://repo.ius.io/ius-release-el7.rpm \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/locale.conf \
    && yum -y install redis5 \
    && sed -i "s/protected-mode yes/protected-mode no/g" /etc/redis.conf \
    && sed -i "s/bind 127.0.0.1/bind 0.0.0.0/g" /etc/redis.conf \
    && sed -i "561i maxmemory-policy allkeys-lru" /etc/redis.conf \
    && yum clean all \
    && rm -rf /var/cache/yum/*

COPY redis/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
