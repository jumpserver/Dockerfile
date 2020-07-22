FROM centos:7
WORKDIR /opt
ARG Version=v2.1.0
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=en_US.utf8" > /etc/locale.conf \
    && yum -y install wget gcc epel-release git yum-utils \
    && yum -y install python36 python36-devel \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm https://mirrors.aliyun.com/rpmfusion/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm \
    && yum install -y java-1.8.0-openjdk \
    && yum install -y cairo-devel libjpeg-turbo-devel libpng-devel libtool uuid-devel \
    && yum install -y ffmpeg-devel freerdp-devel libssh2-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libvorbis-devel libwebp-devel \
    && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key" > /etc/yum.repos.d/nginx.repo \
    && rpm --import https://nginx.org/keys/nginx_signing.key \
    && yum -y install mariadb mariadb-devel mariadb-server redis nginx \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && mkdir -p /config/guacamole /config/guacamole/lib /config/guacamole/extensions /config/guacamole/record /config/guacamole/drive \
    && chown daemon:daemon /config/guacamole/record /config/guacamole/drive \
    && TOMCAT_VER=`curl -s http://tomcat.apache.org/tomcat-9.0-doc/ | grep 'Version ' | awk '{print $2}' | sed 's/.$//'` \
    && wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar -xf apache-tomcat-${TOMCAT_VER}.tar.gz -C /config \
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
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-${Version}-linux-amd64.tar.gz \
    && tar -xf koko-${Version}-linux-amd64.tar.gz \
    && mv koko-${Version}-linux-amd64 koko \
    && wget -O guacamole-${Version}.tar.gz https://github.com/jumpserver/docker-guacamole/archive/${Version}.tar.gz \
    && mkdir /opt/docker-guacamole \
    && tar -xf guacamole-${Version}.tar.gz -C /opt/docker-guacamole --strip-components 1 \
    && mv docker-guacamole-${Version} guacamole \
    && wget https://github.com/jumpserver/lina/releases/download/${Version}/lina-${Version}.tar.gz \
    && tar -xf lina-${Version}.tar.gz \
    && mv lina-${Version} lina \
    && wget https://github.com/jumpserver/luna/releases/download/${Version}/luna-${Version}.tar.gz \
    && tar -xf luna-${Version}.tar.gz \
    && mv luna-${Version} luna \
    && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) \
    && python3.6 -m venv /opt/py3 \
    && echo -e "[easy_install]\nindex_url = https://mirrors.aliyun.com/pypi/simple/" > ~/.pydistutils.cfg \
    && source /opt/py3/bin/activate \
    && pip install wheel \
    && pip install --upgrade pip setuptools \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && cd guacamole \
    && tar -xf guacamole-server-1.2.0.tar.gz \
    && cd guacamole-server-1.2.0 \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && cd .. \
    && ln -sf /opt/guacamole/guacamole-1.0.0.war /config/tomcat9/webapps/ROOT.war \
    && ln -sf /opt/guacamole/guacamole-auth-jumpserver-1.0.0.jar /config/guacamole/extensions/guacamole-auth-jumpserver-1.0.0.jar \
    && ln -sf /opt/guacamole/root/app/guacamole/guacamole.properties /config/guacamole/guacamole.properties \
    && rm -rf guacamole-server-1.2.0 \
    && tar -xf ssh-forward.tar.gz -C /bin/ \
    && chmod +x /bin/ssh-forward \
    && ldconfig \
    && cd /opt \
    && wget -O /etc/nginx/conf.d/jumpserver.conf https://demo.jumpserver.org/download/nginx/conf.d/latest/jumpserver.conf \
    && chown -R root:root /opt/* \
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /opt/*.tar.gz \
    && rm -rf /var/cache/yum/* \
    && rm -rf ~/.cache/pip

COPY allinone/readme.txt readme.txt
COPY allinone/entrypoint.sh .
RUN chmod +x ./entrypoint.sh

VOLUME /opt/jumpserver/data
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
