#!/bin/bash
#

until /usr/local/bin/check ${CORE_HOST}/api/health/; do
    echo "wait for jms_core ${CORE_HOST} ready"
    sleep 2
done

if [ ! "$LOG_LEVEL" ]; then
    export LOG_LEVEL=ERROR
fi

cd /opt/koko
./koko
