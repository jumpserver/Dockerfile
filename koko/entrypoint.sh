#!/bin/bash
#

while [ "$(curl -I -m 10 -L -k -o /dev/null -s -w %{http_code} ${CORE_HOST}/api/health/)" != "200" ]
do
    echo "wait for jms_core ${CORE_HOST} ready"
    sleep 2
done

if [ ! "$LOG_LEVEL" ]; then
    export LOG_LEVEL=ERROR
fi

cd /opt/koko
./koko
