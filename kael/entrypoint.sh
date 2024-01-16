#!/bin/bash
#

until /usr/local/bin/check ${CORE_HOST}/api/health/; do
    echo "wait for jms_core ${CORE_HOST} ready"
    sleep 2
done

export WORK_DIR=/opt/kael
export COMPONENT_NAME=kael
export EXECUTE_PROGRAM=/opt/kael/kael

if [ ! "$LOG_LEVEL" ]; then
    export LOG_LEVEL=ERROR
fi

cd /opt/kael
wisp
