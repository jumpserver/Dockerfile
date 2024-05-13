#!/bin/bash
#

rm -f /opt/jumpserver/tmp/*.pid

if [ "$1" = "start" ]; then
    set -- /opt/jumpserver/jms "$@"
fi

exec "$@"