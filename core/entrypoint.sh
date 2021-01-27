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

if [ ! "$LOG_LEVEL" ]; then
    export LOG_LEVEL=ERROR
fi

action="${1-start}"
if [ ! "${action}" ]; then
  action=start
fi

service="${2-all}"
if [ ! "${service}" ]; then
  service=all
fi

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    echo > /opt/jumpserver/config.yml
fi

if [ ! $LOG_LEVEL ]; then
    export LOG_LEVEL=ERROR
fi

if [[ "$action" == "bash" || "$action" == "sh" ]];then
    bash
else
    source /opt/py3/bin/activate
    cd /opt/jumpserver
    ./jms "${action}" "${service}"
fi
