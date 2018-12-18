FROM centos:latest
LABEL maintainer "wojiushixiaobai"
WORKDIR /opt

RUN set -ex \
	&& ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 \
    && export LC_ALL=zh_CN.UTF-8 \
    && echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf \
    && yum -y install wget gcc epel-release git \
    && yum -y install python36 python36-devel \
    && yum clean all \
    && rm -rf /var/cache/yum/*
