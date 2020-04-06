FROM centos:7
WORKDIR /opt
ARG Version=1.5.7
ENV Version=${Version} \
    LC_ALL=en_US.UTF-8

RUN set -ex \
    && yum install -y epel-release wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key\nmodule_hotfixes=true" > /etc/yum.repos.d/nginx.repo \
    && yum install -y nginx \
    && echo > /etc/nginx/conf.d/default.conf \
    && wget https://github.com/jumpserver/luna/releases/download/${Version}/luna.tar.gz \
    && tar -xf luna.tar.gz \
    && chown -R root:root luna \
    && rm -rf luna.tar.gz \
    && yum remove -y wget \
    && yum clean all \
    && rm -rf /var/tmp/yum*

COPY nginx/nginx.conf /etc/nginx/

CMD ["nginx", "-g", "daemon off;"]
