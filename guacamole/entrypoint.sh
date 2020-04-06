#!/bin/bash
#

if [ ! $JUMPSERVER_KEY_DIR ]; then
    export JUMPSERVER_KEY_DIR=/config/guacamole/keys
fi
if [ ! $GUACAMOLE_HOME ]; then
    export GUACAMOLE_HOME=/config/guacamole
fi
if [ ! $GUACAMOLE_LOG_LEVEL ]; then
    export GUACAMOLE_LOG_LEVEL=ERROR
fi
if [ ! $JUMPSERVER_ENABLE_DRIVE ]; then
    export JUMPSERVER_ENABLE_DRIVE=true
fi
if [ ! $JUMPSERVER_CLEAR_DRIVE_SESSION ]; then
    export JUMPSERVER_CLEAR_DRIVE_SESSION=true
fi

rm -rf /config/guacamole/data/log/*
rm -rf /config/tomcat9/logs/*

sleep 5s
while [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} $JUMPSERVER_SERVER)" != "302" ]
do
    echo "wait for jms_core ready"
    sleep 2
done

guacd &
cd /config/tomcat9/bin && ./startup.sh

echo "Guacamole version $Version, more see https://www.jumpserver.org"
echo "Quit the server with CONTROL-C."

if [ ! -f "/config/guacamole/data/log/info.log" ]; then
    echo "" > /config/guacamole/data/log/info.log
fi

tail -f /config/guacamole/data/log/info.log
