FROM centos:7.5.1804
LABEL maintainer "wojiushixiaobai"
WORKDIR /opt

RUN set -ex \
    && yum provides '*/applydeltarpm' \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 \
    && yum install -y deltarpm \
    && yum update -y \
    && yum install -y wget tar libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make \
    && wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz \
    && tar xf Python-3.6.1.tar.xz \
    && cd Python-3.6.1 \
    && ./configure --enable-optimizations \
    && make \
    && make install \
    && make clean \
    && rm -rf /opt/Python-3.6.1* \
    && yum clean all \
    && rm -rf /var/cache/yum/*
