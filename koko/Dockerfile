FROM centos:8
WORKDIR /opt
ARG TARGETARCH \
    Version=v2.9.2
ENV Version=${Version}

RUN set -ex \
   && yum install -y wget dnf-plugins-core glibc-langpack-en \
   && yum config-manager --set-enable powertools \
   && yum config-manager --enable devel \
   && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
   && yum -y install mariadb bash-completion nc \
   && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-${Version}-linux-${TARGETARCH}.tar.gz \
   && tar -xf koko-${Version}-linux-${TARGETARCH}.tar.gz \
   && mv koko-${Version}-linux-${TARGETARCH} koko \
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
   && yum config-manager --disable devel \
   && rm -rf /var/cache/yum*

COPY koko/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD [ "./entrypoint.sh" ]
