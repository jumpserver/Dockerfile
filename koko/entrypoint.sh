#!/bin/bash
#

sleep 5s
while [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} $CORE_HOST)" != "302" ]
do
    echo "wait for jms_core ready"
    sleep 2
done

function config_koko() {
    cp /opt/koko/config_example.yml /opt/koko/config.yml
    sed -i '5d' /opt/koko/config.yml
    sed -i "5i CORE_HOST: $CORE_HOST" /opt/koko/config.yml
    sed -i "s/BOOTSTRAP_TOKEN: <PleasgeChangeSameWithJumpserver>/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/koko/config.yml
    sed -i "s/# LOG_LEVEL: INFO/LOG_LEVEL: ERROR/g" /opt/koko/config.yml
    sed -i "s@# SFTP_ROOT: /tmp@SFTP_ROOT: /@g" /opt/koko/config.yml
}

function config_redis() {
    sed -i "s/# SHARE_ROOM_TYPE: local/SHARE_ROOM_TYPE: redis/g" /opt/koko/config.yml
    sed -i "s/# REDIS_HOST: 127.0.0.1/REDIS_HOST: $REDIS_HOST/g" /opt/koko/config.yml
    sed -i "s/# REDIS_PORT: 6379/REDIS_PORT: $REDIS_PORT/g" /opt/koko/config.yml
    sed -i "s/# REDIS_PASSWORD:/REDIS_PASSWORD: $REDIS_PASSWORD/g" /opt/koko/config.yml
    sed -i "s/# REDIS_DB_ROOM:/REDIS_DB_ROOM: 6/g" /opt/koko/config.yml
}

if [ ! -f "/opt/koko/config.yml" ]; then
    config_koko
    if [ $REDIS_HOST ]; then
        config_redis
    fi
fi


cd /opt/koko
./koko
