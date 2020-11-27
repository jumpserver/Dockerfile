FROM centos:7
WORKDIR /opt
ARG Version=v2.5.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && yum install -y epel-release wget \
    && yum clean all \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=en_US.utf8" > /etc/locale.conf \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm \
    && yum install -y make gcc java-1.8.0-openjdk \
    && yum install -y cairo-devel libjpeg-turbo-devel libpng-devel libtool uuid-devel \
    && yum install -y ffmpeg-devel freerdp-devel pango-devel libssh2-devel libtelnet-devel libvncserver-devel libwebsockets-devel pulseaudio-libs-devel openssl-devel libvorbis-devel libwebp-devel \
    && mkdir -p /config/guacamole /config/guacamole/data /config/guacamole/lib /config/guacamole/extensions /config/guacamole/data/log/ /config/guacamole/record /config/guacamole/drive \
    && chown daemon:daemon /config/guacamole/record /config/guacamole/drive \
    && cd /config \
    && TOMCAT_VER=`curl -s http://tomcat.apache.org/tomcat-9.0-doc/ | grep 'Version ' | awk '{print $2}' | sed 's/.$//'` \
    && wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar -xf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VER} tomcat9 \
    && rm -rf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && rm -rf tomcat9/webapps/* \
    && sed -i 's/# export/export/g' /root/.bashrc \
    && sed -i 's/# alias l/alias l/g' /root/.bashrc \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /config/tomcat9/conf/logging.properties \
    && wget -O docker-guacamole-${Version}.tar.gz https://github.com/jumpserver/docker-guacamole/archive/master.tar.gz \
    && mkdir /config/docker-guacamole \
    && tar -xf docker-guacamole-${Version}.tar.gz -C /config/docker-guacamole --strip-components 1 \
    && rm -rf docker-guacamole-${Version}.tar.gz \
    && chown -R root:root /config/docker-guacamole \
    && cd /config/docker-guacamole \
    && wget http://download.jumpserver.org/public/guacamole-server-1.2.0.tar.gz \
    && tar -xf guacamole-server-1.2.0.tar.gz \
    && cd guacamole-server-1.2.0 \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig \
    && cd .. \
    && wget http://download.jumpserver.org/public/ssh-forward.tar.gz \
    && tar -xf ssh-forward.tar.gz -C /bin/ \
    && chmod 755 /bin/ssh-forward \
    && wget http://download.jumpserver.org/release/${Version}/guacamole-client-${Version}.tar.gz \
    && tar -xf guacamole-client-${Version}.tar.gz \
    && cp guacamole-client-${Version}/guacamole-*.war /config/tomcat9/webapps/ROOT.war \
    && cp guacamole-client-${Version}/guacamole-*.jar /config/guacamole/extensions/ \
    && cd /config \
    && mv /config/docker-guacamole/guacamole.properties /config/guacamole/ \
    && yum -y remove libwinpr \
    && yum localinstall -y https://demo.jumpserver.org/download/centos/7/libwinpr-2.0.0-4.rc4.el7_8.x86_64.rpm https://demo.jumpserver.org/download/centos/7/libwinpr-devel-2.0.0-4.rc4.el7_8.x86_64.rpm https://demo.jumpserver.org/download/centos/7/freerdp-libs-2.0.0-4.rc4.el7_8.x86_64.rpm https://demo.jumpserver.org/download/centos/7/freerdp-devel-2.0.0-4.rc4.el7_8.x86_64.rpm \
    && rm -rf /config/docker-guacamole \
    && yum clean all \
    && rm -rf /var/tmp/yum*

COPY guacamole/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
