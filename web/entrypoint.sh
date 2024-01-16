#!/bin/bash
#

if [ -f "/etc/init.d/cron" ]; then
  /etc/init.d/cron start
fi

nginx -g "daemon off;"
