#!/bin/bash
#
action="${1}"

if [[ "$action" == "bash" || "$action" == "sh" ]]; then
    bash
    exit 0
fi

echo

if [ ! "${DB_HOST}" ] || [ ! "${DB_PORT}" ] || [ ! "${REDIS_HOST}" ] || [ ! "${REDIS_PORT}" ]; then
    echo -e "\033[31m Please set database environment \033[0m"
    exit 1
fi

while ! nc -z "${DB_HOST}" "${DB_PORT}";
do
    echo "wait for jms_mysql ${DB_HOST} ready"
    sleep 2s
done

while ! nc -z "${REDIS_HOST}" "${REDIS_PORT}";
do
    echo "wait for jms_redis ${REDIS_HOST} ready"
    sleep 2s
done

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    echo > /opt/jumpserver/config.yml
fi

if [ ! -d "/opt/jumpserver/data/media/replay" ]; then
   mkdir -p /opt/jumpserver/data/media/replay
   chmod 755 -R /opt/jumpserver/data/media/replay
fi

if [ ! -d "/opt/jumpserver/data/static" ]; then
    mkdir -p /opt/jumpserver/data/static
    chmod 755 -R /opt/jumpserver/data/static
fi

if [ -f "/opt/readme.txt" ]; then
  sed -i "s@VERSION:.*@VERSION: ${VERSION}@g" /opt/readme.txt
fi

rm -f /opt/jumpserver/tmp/*.pid

if [ ! "${LOG_LEVEL}" ]; then
    export LOG_LEVEL=ERROR
fi
sed -i "s@root: INFO@root: ${LOG_LEVEL}@g" /opt/chen/config/application.yml
sed -i "s@address: static://127.0.0.1:9090@address: static://127.0.0.1:9092@g" /opt/chen/config/application.yml

if [ -f "/etc/init.d/cron" ]; then
  /etc/init.d/cron start
fi

if [ "$(uname -m)" = "loongarch64" ]; then
    export SECURITY_LOGIN_CAPTCHA_ENABLED=False
fi

cd /opt/jumpserver || exit 1
./jms upgrade_db || {
    echo -e "\033[31m Failed to change the table structure. \033[0m"
    exit 1
}

echo
echo "Time: $(date "+%Y-%m-%d %H:%M:%S")"
if [ -f "/opt/readme.txt" ]; then
  cat /opt/readme.txt
  rm -f /opt/readme.txt
fi

echo
echo "LOG_LEVEL: ${LOG_LEVEL}"
echo "JumpServer Logs:"

/etc/init.d/nginx start
/etc/init.d/supervisor start