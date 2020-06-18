FROM centos:7
WORKDIR /opt
ARG Version=2.0.0
ENV Version=${Version} \
    GUAC_VER=1.0.0 \
    TOMCAT_VER=9.0.36 \
    LANG=en_US.utf8

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=en_US.utf8" > /etc/locale.conf \
    && yum -y install wget gcc epel-release git yum-utils \
    && yum -y install python36 python36-devel \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.aliyun.com/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm \
    && yum install -y java-1.8.0-openjdk libtool \
    && mkdir /usr/local/lib/freerdp/ \
    && ln -s /usr/local/lib/freerdp /usr/lib64/freerdp \
    && yum install -y cairo-devel libjpeg-turbo-devel libpng-devel uuid-devel \
    && yum install -y ffmpeg-devel freerdp1.2-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libvorbis-devel libwebp-devel \
    && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key" > /etc/yum.repos.d/nginx.repo \
    && rpm --import https://nginx.org/keys/nginx_signing.key \
    && yum -y install mariadb mariadb-devel mariadb-server redis nginx \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && mkdir -p /config/guacamole /config/guacamole/lib /config/guacamole/extensions /config/guacamole/record /config/guacamole/drive \
    && chown daemon:daemon /config/guacamole/record /config/guacamole/drive \
    && wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar xf apache-tomcat-${TOMCAT_VER}.tar.gz -C /config \
    && rm -rf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && mv /config/apache-tomcat-${TOMCAT_VER} /config/tomcat9 \
    && rm -rf /config/tomcat9/webapps/* \
    && sed -i 's/Connector port="8080"/Connector port="8081"/g' /config/tomcat9/conf/server.xml \
    && sed -i 's/level = FINE/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's/level = INFO/level = OFF/g' /config/tomcat9/conf/logging.properties \
    && sed -i 's@CATALINA_OUT="$CATALINA_BASE"/logs/catalina.out@CATALINA_OUT=/dev/null@g' /config/tomcat9/bin/catalina.sh \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /config/tomcat9/conf/logging.properties \
    && yum clean all \
    && rm -rf /var/cache/yum/*

RUN set -ex \
    && wget -O jumpserver.tar.gz https://github.com/jumpserver/jumpserver/archive/${Version}.tar.gz \
    && tar -xf ${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-master-linux-amd64.tar.gz \
    && tar -xf koko-master-linux-amd64.tar.gz \
    && mv kokodir koko \
    && wget -O guacamole.tar.gz https://github.com/jumpserver/docker-guacamole/archive/${Version}.tar.gz \
    && tar -xf guacamole.tar.gz \
    && mv docker-guacamole-${Version} guacamole \
    && wget https://github.com/jumpserver/lina/releases/download/${Version}/lina.tar.gz \
    && tar -xf lina.tar.gz \
    && wget https://github.com/jumpserver/luna/releases/download/${Version}/luna.tar.gz \
    && tar xf luna.tar.gz \
    && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) \
    && python3.6 -m venv /opt/py3 \
    && echo -e "[easy_install]\nindex_url = https://mirrors.aliyun.com/pypi/simple/" > ~/.pydistutils.cfg \
    && source /opt/py3/bin/activate \
    && pip install wheel \
    && pip install --upgrade pip setuptools \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && cd docker-guacamole \
    && tar xf guacamole-server-${GUAC_VER}.tar.gz \
    && cd guacamole-server-${GUAC_VER} \
    && autoreconf -fi \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && cd .. \
    && ln -sf /opt/docker-guacamole/guacamole-${GUAC_VER}.war /config/tomcat9/webapps/ROOT.war \
    && ln -sf /opt/docker-guacamole/guacamole-auth-jumpserver-${GUAC_VER}.jar /config/guacamole/extensions/guacamole-auth-jumpserver-${GUAC_VER}.jar \
    && ln -sf /opt/docker-guacamole/root/app/guacamole/guacamole.properties /config/guacamole/guacamole.properties \
    && rm -rf guacamole-server-${GUAC_VER} \
    && tar xf ssh-forward.tar.gz -C /bin/ \
    && chmod +x /bin/ssh-forward \
    && ldconfig \
    && cd /opt \
    && wget -O /etc/nginx/conf.d/jumpserver.conf https://demo.jumpserver.org/download/nginx/conf.d/${Version}/jumpserver.conf \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /opt/*.tar.gz \
    && rm -rf /var/cache/yum/* \
    && rm -rf ~/.cache/pip

COPY allinone/readme.txt readme.txt
COPY allinone/entrypoint.sh .
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data/media
VOLUME /var/lib/mysql

ENV SECRET_KEY=kWQdmdCQKjaWlHYpPhkNQDkfaRulM6YnHctsHLlSPs8287o2kW \
    BOOTSTRAP_TOKEN=KXOeyNgDeTdpeu9q \
    DB_ENGINE=mysql \
    DB_HOST=127.0.0.1 \
    DB_PORT=3306 \
    DB_USER=jumpserver \
    DB_PASSWORD=weakPassword \
    DB_NAME=jumpserver \
    REDIS_HOST=127.0.0.1 \
    REDIS_PORT=6379 \
    REDIS_PASSWORD= \
    JUMPSERVER_KEY_DIR=/config/guacamole/keys \
    GUACAMOLE_HOME=/config/guacamole \
    GUACAMOLE_LOG_LEVEL=ERROR \
    JUMPSERVER_ENABLE_DRIVE=true \
    JUMPSERVER_SERVER=http://127.0.0.1:8080

EXPOSE 80 2222
ENTRYPOINT ["./entrypoint.sh"]
