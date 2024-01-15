#!/bin/bash
#

until /usr/local/bin/check ${CORE_HOST}/api/health/; do
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

if [ ! -d "/opt/lion/data/logs" ]; then
    mkdir -p /opt/lion/data/logs
    touch /opt/lion/data/logs/guacd.log
fi

supervisord
