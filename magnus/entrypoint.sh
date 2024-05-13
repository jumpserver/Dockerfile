#!/bin/bash
#

if [ -n "$CORE_HOST" ]; then
    until check ${CORE_HOST}/api/health/; do
        echo "wait for jms_core ${CORE_HOST} ready"
        sleep 2
    done
fi

export WORK_DIR=/opt/magnus
export COMPONENT_NAME=magnus
export WISP_TRACE_PROCESS=1
export EXECUTE_PROGRAM=/opt/magnus/magnus

if [ ! "$LOG_LEVEL" ]; then
    export LOG_LEVEL=ERROR
fi

exec "$@"