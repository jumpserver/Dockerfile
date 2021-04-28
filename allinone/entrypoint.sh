#!/bin/bash
#

while ! nc -z $DB_HOST $DB_PORT;
do
    echo "wait for jms_mysql ${DB_HOST} ready"
    sleep 2s
done

while ! nc -z $REDIS_HOST $REDIS_PORT;
do
    echo "wait for jms_redis ${REDIS_HOST} ready"
    sleep 2s
done

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    echo > /opt/jumpserver/config.yml
fi

. /opt/py3/bin/activate
cd /opt/jumpserver && ./jms start -d
cd /opt/koko && ./koko -d
/etc/init.d/guacd start
sh /config/tomcat9/bin/startup.sh
/usr/sbin/nginx &

echo "Jumpserver ALL $Version"
tail -f /opt/readme.txt
