#!/bin/bash
#

function config_redis {
    if [ "$REDIS_PORT" != "6379" ]; then
        sed -i "s/port 6379/port $REDIS_PORT/g" /etc/redis.conf
    fi
    if [ ! "$(cat /etc/redis.conf | grep -v ^\# | grep requirepass | awk '{print $2}')" ]; then
        sed -i "481i requirepass $REDIS_PASSWORD" /etc/redis.conf
    else
        sed -i "s/requirepass .*/requirepass $REDIS_PASSWORD/" /etc/redis.conf
    fi
}

config_redis
redis-server --version
redis-server /etc/redis.conf

if [ ! -d "/var/log/redis" ]; then
    mkdir -p /var/log/redis
fi
if [ ! -f "/var/log/redis/redis.log" ]; then
    echo > /var/log/redis/redis.log
fi
tail -f /var/log/redis/redis.log
