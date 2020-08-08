#!/bin/bash
#

sleep 5s
while ! nc -z $DB_HOST $DB_PORT;
do
    echo "wait for jms_mysql ready"
    sleep 2s
done

while ! nc -z $REDIS_HOST $REDIS_PORT;
do
    echo "wait for jms_redis ready"
    sleep 2s
done

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    echo > /opt/jumpserver/config.yml
fi

if [ ! $LOG_LEVEL ]; then
    export LOG_LEVEL=ERROR
fi

if [ ! $WINDOWS_SKIP_ALL_MANUAL_PASSWORD ]; then
    export WINDOWS_SKIP_ALL_MANUAL_PASSWORD=True
fi

source /opt/py3/bin/activate
cd /opt/jumpserver && ./jms start
