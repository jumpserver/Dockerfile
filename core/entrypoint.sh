#!/bin/bash
#

sleep 5s
while ! nc -z $DB_HOST $DB_PORT;
do
    echo "wait for jms_mysql ready"
    sleep 2s
done

while ! nc -z $REDIS_HOST $REDIS_PORT;
do
    echo "wait for jms_redis ready"
    sleep 2s
done

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    cp /opt/jumpserver/config_example.yml /opt/jumpserver/config.yml
    sed -i "s/SECRET_KEY:/SECRET_KEY: $SECRET_KEY/g" /opt/jumpserver/config.yml
    sed -i "s/BOOTSTRAP_TOKEN:/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/jumpserver/config.yml
    sed -i "s/# DEBUG: true/DEBUG: false/g" /opt/jumpserver/config.yml
    sed -i "s/# LOG_LEVEL: DEBUG/LOG_LEVEL: ERROR/g" /opt/jumpserver/config.yml
    sed -i "s/# SESSION_EXPIRE_AT_BROWSER_CLOSE: false/SESSION_EXPIRE_AT_BROWSER_CLOSE: true/g" /opt/jumpserver/config.yml
    sed -i "s/DB_HOST: 127.0.0.1/DB_HOST: $DB_HOST/g" /opt/jumpserver/config.yml
    sed -i "s/DB_PORT: 3306/DB_PORT: $DB_PORT/g" /opt/jumpserver/config.yml
    sed -i "s/DB_USER: jumpserver/DB_USER: $DB_USER/g" /opt/jumpserver/config.yml
    sed -i "s/DB_PASSWORD: /DB_PASSWORD: $DB_PASSWORD/g" /opt/jumpserver/config.yml
    sed -i "s/DB_NAME: jumpserver/DB_NAME: $DB_NAME/g" /opt/jumpserver/config.yml
    sed -i "s/REDIS_HOST: 127.0.0.1/REDIS_HOST: $REDIS_HOST/g" /opt/jumpserver/config.yml
    sed -i "s/REDIS_PORT: 6379/REDIS_PORT: $REDIS_PORT/g" /opt/jumpserver/config.yml
    sed -i "s/# REDIS_PASSWORD: /REDIS_PASSWORD: $REDIS_PASSWORD/g" /opt/jumpserver/config.yml
    sed -i "s/# WINDOWS_SKIP_ALL_MANUAL_PASSWORD: False/WINDOWS_SKIP_ALL_MANUAL_PASSWORD: True/g" /opt/jumpserver/config.yml
fi

source /opt/py3/bin/activate
cd /opt/jumpserver && ./jms start
