FROM centos:7
WORKDIR /opt
ARG Version=1.5.7
ENV Version=${Version} \
    LC_ALL=en_US.UTF-8 \
    GUAC_VER=1.0.0 \
    TOMCAT_VER=9.0.33

RUN set -ex \
    && yum install -y epel-release wget \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir /usr/local/lib/freerdp/ \
    && ln -s /usr/local/lib/freerdp /usr/lib64/freerdp \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.aliyun.com/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm \
    && yum install -y make gcc libtool java-1.8.0-openjdk wget unzip \
    && yum install -y cairo-devel libjpeg-turbo-devel libpng-devel uuid-devel \
    && yum install -y ffmpeg-devel freerdp1.2-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libvorbis-devel libwebp-devel \
    && mkdir -p /config/guacamole /config/guacamole/lib /config/guacamole/extensions /config/guacamole/data/log/ /config/guacamole/record /config/guacamole/drive \
    && chown daemon:daemon /config/guacamole/record /config/guacamole/drive \
    && cd /config \
    && wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar xf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VER} tomcat9 \
    && rm -rf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && rm -rf tomcat9/webapps/* \
    && sed -i 's/level = FINE/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's/level = INFO/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's@CATALINA_OUT="$CATALINA_BASE"/logs/catalina.out@CATALINA_OUT=/dev/null@g' /config/tomcat9/bin/catalina.sh \
    && sed -i 's/# export/export/g' /root/.bashrc \
    && sed -i 's/# alias l/alias l/g' /root/.bashrc \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /config/tomcat9/conf/logging.properties \
    && wget https://github.com/jumpserver/docker-guacamole/archive/${Version}.zip \
    && unzip ${Version}.zip \
    && rm -rf ${Version}.zip \
    && mv docker-guacamole-${Version} docker-guacamole \
    && chown -R root:root docker-guacamole \
    && cd /config/docker-guacamole \
    && tar xf guacamole-server-${GUAC_VER}.tar.gz \
    && cd guacamole-server-${GUAC_VER} \
    && autoreconf -fi \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig \
    && cd .. \
    && rm -rf guacamole-server-${GUAC_VER} \
    && cd /config \
    && mv /config/docker-guacamole/guacamole-${GUAC_VER}.war /config/tomcat9/webapps/ROOT.war \
    && mv /config/docker-guacamole/guacamole-auth-jumpserver-${GUAC_VER}.jar /config/guacamole/extensions/guacamole-auth-jumpserver-${GUAC_VER}.jar \
    && mv /config/docker-guacamole/root/app/guacamole/guacamole.properties /config/guacamole/guacamole.properties \
    && wget https://github.com/ibuler/ssh-forward/releases/download/v0.0.5/linux-amd64.tar.gz \
    && tar xf linux-amd64.tar.gz -C /bin/ \
    && chmod +x /bin/ssh-forward \
    && yum remove -y wget gcc make unzip \
    && rm -rf /config/linux-amd64.tar.gz \
    && rm -rf /config/docker-guacamole \
    && yum clean all \
    && rm -rf /var/tmp/yum*

COPY guacamole/entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

CMD ["./entrypoint.sh"]
