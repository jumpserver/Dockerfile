#!/bin/bash
#

while ! nc -z $DB_HOST $DB_PORT;
do
    echo "wait for jms_mysql ${DB_HOST} ready"
    sleep 2s
done

if [ $REDIS_HOST == 127.0.0.1 ]; then
    sed -i "s@# requirepass .*@requirepass $REDIS_PASSWORD@g" /etc/redis.conf
    /etc/init.d/redis-server start
fi

while ! nc -z $REDIS_HOST $REDIS_PORT;
do
    echo "wait for jms_redis ${REDIS_HOST} ready"
    sleep 2s
done

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    echo > /opt/jumpserver/config.yml
fi

if [ ! -d "/opt/jumpserver/data/static" ]; then
    mkdir -p /opt/jumpserver/data/static
    chmod 755 -R /opt/jumpserver/data/static
fi

. /opt/py3/bin/activate
cd /opt/jumpserver && ./jms start -d
/etc/init.d/supervisor start
/etc/init.d/nginx start

echo "Jumpserver ALL $Version"
tail -f /opt/readme.txt
