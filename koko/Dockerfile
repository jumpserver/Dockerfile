FROM centos:7
WORKDIR /opt
ARG Version=v2.5.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
   && yum install -y wget \
   && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
   && echo "LANG=en_US.utf8" > /etc/locale.conf \
   && yum -y localinstall http://mirrors.ustc.edu.cn/mysql-repo/mysql57-community-release-el7.rpm \
   && yum -y install mysql-community-client bash-completion \
   && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-${Version}-linux-amd64.tar.gz \
   && tar -xf koko-${Version}-linux-amd64.tar.gz \
   && mv koko-${Version}-linux-amd64 koko \
   && chown -R root:root koko \
   && mv /opt/koko/kubectl /usr/local/bin/ \
   && wget https://download.jumpserver.org/public/kubectl.tar.gz \
   && tar -xf kubectl.tar.gz \
   && chmod 755 ./kubectl \
   && chown root:root ./kubectl \
   && mv kubectl /usr/local/bin/rawkubectl \
   && wget http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
   && mkdir /opt/kubectl-aliases/ \
   && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
   && chown -R root:root /opt/kubectl-aliases/ \
   && chmod 755 /opt/koko/init-kubectl.sh \
   && rm -rf /opt/*.tar.gz \
   && yum clean all \
   && rm -rf /var/cache/yum*

COPY koko/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD [ "./entrypoint.sh" ]
