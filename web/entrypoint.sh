#!/bin/bash
#

if [ -n "$CORE_HOST" ]; then
    until check ${CORE_HOST}/api/health/; do
        echo "wait for jms_core ${CORE_HOST} ready"
        sleep 2
    done
fi

if [ -f "/etc/init.d/cron" ]; then
  /etc/init.d/cron start
fi