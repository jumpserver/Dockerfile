FROM centos:7
WORKDIR /opt
ARG Version=v2.2.0
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && yum install -y epel-release \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=en_US.utf8" > /etc/locale.conf \
    && echo -e "# MariaDB 10.5 CentOS repository list - created 2020-11-18 06:35 UTC\n# http://downloads.mariadb.org/mariadb/repositories/\n[mariadb]\nname = MariaDB\nbaseurl = http://yum.mariadb.org/10.5/centos7-amd64\ngpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck=1" > /etc/yum.repos.d/mariadb.repo \
    && sed -i 's#yum\.mariadb\.org#mirrors.ustc.edu.cn/mariadb/yum#' /etc/yum.repos.d/mariadb.repo \
    && sed -i 's#http://mirrors\.ustc\.edu\.cn#https://mirrors.ustc.edu.cn#g' /etc/yum.repos.d/mariadb.repo \
    && yum -y install mariadb-server mariadb-client \
    && yum clean all \
    && rm -rf /var/cache/yum/*

COPY mysql/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
