#!/bin/bash
#

until /usr/local/bin/check ${CORE_HOST}/api/health/; do
    echo "wait for jms_core ${CORE_HOST} ready"
    sleep 2
done

export GIN_MODE=release
export WORK_DIR=/opt/chen
export COMPONENT_NAME=chen
export WISP_TRACE_PROCESS=1
export EXECUTE_PROGRAM="java -Dfile.encoding=utf-8 -XX:+ExitOnOutOfMemoryError -jar /opt/chen/chen.jar --mock.enable=false"

if [ ! "$LOG_LEVEL" ]; then
    LOG_LEVEL=ERROR
fi

sed -i "s@root: INFO@root: ${LOG_LEVEL}@g" /opt/chen/config/application.yml

cd /opt/chen
wisp