#!/bin/bash
#

if [ -f "/etc/init.d/cron" ]; then
  /etc/init.d/cron start
fi

until /usr/local/bin/check ${CORE_HOST}/api/health/; do
    echo "wait for jms_core ${CORE_HOST} ready"
    sleep 2
done

nginx -g "daemon off;"
