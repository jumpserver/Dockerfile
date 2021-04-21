FROM centos:7
WORKDIR /opt
ARG Version=v2.9.2
ENV Version=${Version} \
    LANG=en_US.utf8

RUN set -ex \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/locale.conf \
    && yum -y install epel-release https://repo.ius.io/ius-release-el7.rpm \
    && yum -y install wget gcc epel-release git yum-utils \
    && yum -y install python36 python36-devel \
    && yum -y localinstall --nogpgcheck https://mirrors.aliyun.com/rpmfusion/free/el/rpmfusion-free-release-7.noarch.rpm \
    && yum install -y java-1.8.0-openjdk \
    && yum install -y cairo-devel libjpeg-turbo-devel libpng-devel libtool uuid-devel \
    && yum install -y ffmpeg-devel freerdp-devel pango-devel libssh2-devel libtelnet-devel libvncserver-devel libwebsockets-devel pulseaudio-libs-devel openssl-devel libvorbis-devel libwebp-devel \
    && echo -e "[nginx-stable]\nname=nginx stable repo\nbaseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/\ngpgcheck=1\nenabled=1\ngpgkey=https://nginx.org/keys/nginx_signing.key" > /etc/yum.repos.d/nginx.repo \
    && rpm --import https://nginx.org/keys/nginx_signing.key \
    && yum -y localinstall http://mirrors.ustc.edu.cn/mysql-repo/mysql57-community-release-el7.rpm \
    && yum -y install mysql-community-server redis5 nginx \
    && python3.6 -m venv /opt/py3 \
    && echo -e "[easy_install]\nindex_url = https://mirrors.aliyun.com/pypi/simple/" > ~/.pydistutils.cfg \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && wget -O /etc/nginx/conf.d/jumpserver.conf https://demo.jumpserver.org/download/nginx/conf.d/latest/jumpserver.conf \
    && yum install -y bash-completion \
    && mkdir -p /config/guacamole/lib /config/guacamole/extensions /config/guacamole/data/log/ /config/guacamole/data/record /config/guacamole/data/drive \
    && TOMCAT_VER=`curl -s http://tomcat.apache.org/tomcat-9.0-doc/ | grep 'Version ' | awk '{print $2}' | sed 's/.$//'` \
    && wget https://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-9/v${TOMCAT_VER}/bin/apache-tomcat-${TOMCAT_VER}.tar.gz \
    && tar -xf apache-tomcat-${TOMCAT_VER}.tar.gz -C /config \
    && rm -rf apache-tomcat-${TOMCAT_VER}.tar.gz \
    && mv /config/apache-tomcat-${TOMCAT_VER} /config/tomcat9 \
    && rm -rf /config/tomcat9/webapps/* \
    && sed -i 's/Connector port="8080"/Connector port="8081"/g' /config/tomcat9/conf/server.xml \
    && echo "java.util.logging.ConsoleHandler.encoding = UTF-8" >> /config/tomcat9/conf/logging.properties \
    && wget http://download.jumpserver.org/public/guacamole-server-1.3.0.tar.gz \
    && tar -xf guacamole-server-1.3.0.tar.gz \
    && cd guacamole-server-1.3.0 \
    && ./configure --with-init-dir=/etc/init.d \
    && make \
    && make install \
    && ldconfig \
    && cd .. \
    && wget http://download.jumpserver.org/release/${Version}/guacamole-client-${Version}.tar.gz \
    && tar -xf guacamole-client-${Version}.tar.gz \
    && cp guacamole-client-${Version}/guacamole-*.war /config/tomcat9/webapps/ROOT.war \
    && cp guacamole-client-${Version}/guacamole-*.jar /config/guacamole/extensions/ \
    && yum clean all \
    && rm -rf guacamole-server-1.3.0 guacamole-server-1.3.0.tar.gz guacamole-client-${Version} guacamole-client-${Version}.tar.gz \
    && rm -rf /var/cache/yum/*

RUN set -ex \
    && wget https://github.com/jumpserver/jumpserver/releases/download/${Version}/jumpserver-${Version}.tar.gz \
    && tar -xf jumpserver-${Version}.tar.gz \
    && mv jumpserver-${Version} jumpserver \
    && wget https://github.com/jumpserver/koko/releases/download/${Version}/koko-${Version}-linux-amd64.tar.gz \
    && tar -xf koko-${Version}-linux-amd64.tar.gz \
    && mv koko-${Version}-linux-amd64 koko \
    && mv /opt/koko/kubectl /usr/local/bin/ \
    && wget https://download.jumpserver.org/public/kubectl.tar.gz \
    && tar -xf kubectl.tar.gz \
    && chmod 755 kubectl \
    && mv kubectl /usr/local/bin/rawkubectl \
    && wget http://download.jumpserver.org/public/kubectl_aliases.tar.gz \
    && mkdir /opt/kubectl-aliases/ \
    && tar -xf kubectl_aliases.tar.gz -C /opt/kubectl-aliases/ \
    && chown -R root:root /opt/kubectl-aliases/ \
    && chmod 755 /opt/koko/init-kubectl.sh \
    && wget -O guacamole-${Version}.tar.gz https://github.com/jumpserver/docker-guacamole/archive/master.tar.gz \
    && mkdir /opt/guacamole \
    && tar -xf guacamole-${Version}.tar.gz -C /opt/guacamole --strip-components 1 \
    && wget https://github.com/jumpserver/lina/releases/download/${Version}/lina-${Version}.tar.gz \
    && tar -xf lina-${Version}.tar.gz \
    && mv lina-${Version} lina \
    && wget https://github.com/jumpserver/luna/releases/download/${Version}/luna-${Version}.tar.gz \
    && tar -xf luna-${Version}.tar.gz \
    && mv luna-${Version} luna \
    && yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) \
    && source /opt/py3/bin/activate \
    && pip install -r /opt/jumpserver/requirements/requirements.txt \
    && cd guacamole \
    && mv /opt/guacamole/guacamole.properties /config/guacamole/ \
    && wget http://download.jumpserver.org/public/ssh-forward.tar.gz \
    && tar -xf ssh-forward.tar.gz -C /bin/ \
    && chmod 755 /bin/ssh-forward \
    && cd /opt \
    && chown -R root:root /opt/* \
    && yum clean all \
    && rm -rf /opt/guacamole \
    && rm -rf /var/cache/yum/* \
    && rm -rf /opt/*.tar.gz \
    && rm -rf /var/cache/yum/* \
    && rm -rf ~/.cache/pip

COPY allinone/readme.txt readme.txt
COPY allinone/entrypoint.sh .
RUN chmod +x ./entrypoint.sh

VOLUME /var/lib/mysql
VOLUME /opt/jumpserver/data
VOLUME /opt/koko/data
VOLUME /config/guacamole/data

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
    CORE_HOST=http://127.0.0.1:8080 \
    LOG_LEVEL=ERROR \
    JUMPSERVER_KEY_DIR=/config/guacamole/data/keys \
    GUACAMOLE_HOME=/config/guacamole \
    GUACAMOLE_LOG_LEVEL=ERROR \
    JUMPSERVER_ENABLE_DRIVE=true \
    JUMPSERVER_RECORD_PATH=/config/guacamole/data/record \
    JUMPSERVER_DRIVE_PATH=/config/guacamole/data/drive \
    JUMPSERVER_CLEAR_DRIVE_SESSION=true \
    JUMPSERVER_CLEAR_DRIVE_SCHEDULE=24 \
    JUMPSERVER_SERVER=http://127.0.0.1:8080 \
    JUMPSERVER_COLOR_DEPTH=32 \
    JUMPSERVER_DPI=120 \
    JUMPSERVER_DISABLE_BITMAP_CACHING=true \
    JUMPSERVER_DISABLE_GLYPH_CACHING=true

EXPOSE 80 2222
ENTRYPOINT ["./entrypoint.sh"]
