#!/bin/bash
#

while [ "$(curl -I -m 10 -L -k -o /dev/null -s -w %{http_code} ${JUMPSERVER_SERVER}/api/health/)" != "200" ]
do
    echo "wait for jms_core ${JUMPSERVER_SERVER} ready"
    sleep 2
done

if [ ! "$JUMPSERVER_KEY_DIR" ]; then
    export JUMPSERVER_KEY_DIR=/config/guacamole/data/keys
fi
if [ ! -d "$JUMPSERVER_KEY_DIR" ]; then
    mkdir -p $JUMPSERVER_KEY_DIR
fi

if [ ! "$GUACAMOLE_HOME" ]; then
    export GUACAMOLE_HOME=/config/guacamole
fi
if [ ! "$GUACAMOLE_LOG_LEVEL" ]; then
    export GUACAMOLE_LOG_LEVEL=ERROR
fi
if [ ! "$JUMPSERVER_ENABLE_DRIVE" ]; then
    export JUMPSERVER_ENABLE_DRIVE=true
fi
if [ ! "$JUMPSERVER_RECORD_PATH" ]; then
    export JUMPSERVER_RECORD_PATH=/config/guacamole/data/record
fi
if [ ! -d "$JUMPSERVER_RECORD_PATH"]; then
    mkdir $JUMPSERVER_RECORD_PATH
fi

if [ ! "$JUMPSERVER_DRIVE_PATH" ]; then
    export JUMPSERVER_DRIVE_PATH=/config/guacamole/data/drive
fi
if [ ! -d "$JUMPSERVER_DRIVE_PATH"]; then
    mkdir -p $JUMPSERVER_DRIVE_PATH
fi

if [ ! "$JUMPSERVER_CLEAR_DRIVE_SESSION" ]; then
    export JUMPSERVER_CLEAR_DRIVE_SESSION=true
fi
if [ ! "$JUMPSERVER_CLEAR_DRIVE_SCHEDULE" ]; then
    export JUMPSERVER_CLEAR_DRIVE_SCHEDULE=24
fi

if [ ! "$JUMPSERVER_COLOR_DEPTH" ]; then
    export JUMPSERVER_COLOR_DEPTH=32
fi
if [ ! "$JUMPSERVER_DPI" ]; then
    export JUMPSERVER_DPI=120
fi

if [ ! "$JUMPSERVER_DISABLE_BITMAP_CACHING" ]; then
    export JUMPSERVER_DISABLE_BITMAP_CACHING=true
fi

if [ ! "$JUMPSERVER_DISABLE_GLYPH_CACHING" ]; then
    export JUMPSERVER_DISABLE_GLYPH_CACHING=true
fi

echo "Guacamole version $Version, more see https://www.jumpserver.org"
echo "Quit the server with CONTROL-C."

if [ ! -d "/config/guacamole/data/log" ]; then
  mkdir -p /config/guacamole/data/log
fi

/etc/init.d/guacd start
cd /config/tomcat9/bin && ./startup.sh

if [ ! -f "/config/guacamole/data/log/info.log" ]; then
    echo "" > /config/guacamole/data/log/info.log
fi

tail -f /config/guacamole/data/log/info.log
