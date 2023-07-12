#!/bin/bash
#

while [ "$(curl -I -m 10 -L -k -o /dev/null -s -w %{http_code} ${CORE_HOST}/api/health/)" != "200" ]
do
    echo "wait for jms_core ${CORE_HOST} ready"
    sleep 2
done

if [ ! "$LOG_LEVEL" ]; then
    LOG_LEVEL=ERROR
fi

case $LOG_LEVEL in
    DEBUG)
        export LOG_LEVEL=DEBUG
        export GUACD_LOG_LEVEL=debug
        ;;
    INFO)
        export LOG_LEVEL=INFO
        export GUACD_LOG_LEVEL=info
        ;;
    WARN)
        export LOG_LEVEL=WARN
        export GUACD_LOG_LEVEL=warning
        ;;
    ERROR)
        export LOG_LEVEL=ERROR
        export GUACD_LOG_LEVEL=error
        ;;
    *)
        export LOG_LEVEL=ERROR
        export GUACD_LOG_LEVEL=error
        ;;
esac

supervisord
