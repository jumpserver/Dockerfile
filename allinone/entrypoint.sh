#!/bin/bash
#

cwd=$(dirname "$(realpath "$0")")
action="${1}"

if [[ "$action" == "bash" || "$action" == "sh" ]]; then
    bash
    exit 0
fi
echo

envs=("DB_PASSWORD" "REDIS_PASSWORD" "SECRET_KEY" "BOOTSTRAP_TOKEN")
for var in "${envs[@]}"; do
    if [[ -z "${!var}" ]];then
        echo "WARN: No ${var} set use unsafe default val"
        export "$var=PleaseChangeMe"
    fi
    echo "$var: ${!var}"
done

cp /opt/jumpserver/config_example.yml /opt/jumpserver/config.yml

if [ ! -d "/opt/jumpserver/data/media/replay" ]; then
   mkdir -p /opt/jumpserver/data/media/replay
   chmod 755 -R /opt/jumpserver/data/media/replay
fi

if [ ! -d "/opt/jumpserver/data/static" ]; then
    mkdir -p /opt/jumpserver/data/static
    chmod 755 -R /opt/jumpserver/data/static
fi

source ${cwd}/start_db.sh

rm -f /opt/jumpserver/tmp/*.pid

if [ ! "${CORE_HOST}" ]; then
    export CORE_HOST=http://localhost:8080
fi

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

export GIN_MODE=release

echo
echo "Time: $(date "+%Y-%m-%d %H:%M:%S")"
if [ -f "/opt/readme.txt" ]; then
  sed -i "s@VERSION:.*@VERSION: ${VERSION}@g" /opt/readme.txt
  cat /opt/readme.txt
  rm -f /opt/readme.txt
fi

echo
echo "LOG_LEVEL: ${LOG_LEVEL}"
echo "JumpServer Logs:"

/etc/init.d/supervisor start
