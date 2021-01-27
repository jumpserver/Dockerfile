#!/bin/bash
#

while [ "$DB_HOST" == "127.0.0.1" ]; do
    echo -e "Error: DB_HOST cannot be set to 127.0.0.1 "
    sleep 2s
done

while [ "$REDIS_HOST" == "127.0.0.1" ]; do
    echo -e "Error: REDIS_HOST cannot be set to 127.0.0.1 "
    sleep 2s
done

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    echo > /opt/jumpserver/config.yml
fi

export CATALINA_HOME=/usr/share/tomcat9
export CATALINA_BASE=/var/lib/tomcat9
export CATALINA_TMPDIR=/tmp
export JAVA_OPTS=-Djava.awt.headless=true
if grep -q "catalina.sh run " /usr/libexec/tomcat9/tomcat-start.sh; then
    sed -i "s@catalina.sh run @catalina.sh start @g" /usr/libexec/tomcat9/tomcat-start.sh
fi

source /opt/py3/bin/activate
cd /opt/jumpserver && ./jms start all -d
cd /opt/koko && ./koko -d
/etc/init.d/guacd start
sh /usr/libexec/tomcat9/tomcat-start.sh
/usr/sbin/nginx

echo "Jumpserver ALL $Version"
tail -f /opt/readme.txt
