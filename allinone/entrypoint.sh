#!/bin/bash
#

cwd=$(dirname "$(realpath "$0")")
action="${1}"

if [[ "$action" == "bash" || "$action" == "sh" ]]; then
    bash
    exit 0
fi
echo

function prepare_core() {
    SECRET_KEY=${SECRET_KEY:-PleaseChangeMe}
    BOOTSTRAP_TOKEN=${BOOTSTRAP_TOKEN:-PleaseChangeMe}
    CORE_HOST=${CORE_HOST:-"http://localhost:8080"}
    LOG_LEVEL=${LOG_LEVEL:-INFO}
    
    export SECRET_KEY BOOTSTRAP_TOKEN CORE_HOST LOG_LEVEL
    export PATH=/opt/py3/bin/:$PATH
    
    if [[ -f /opt/jumpserver/config.yml ]];then
        echo > /opt/jumpserver/config.yml
    fi
    rm -f /opt/jumpserver/tmp/*.pid
}


function mv_dir_link(){
    src=$1
    dst=$2

    mkdir -p ${dst}
    if [[ -d ${src} || ! -L ${src} ]];then
        if [[ ! -z "$(ls -A ${src})" ]];then
            mv ${src}/* ${dst}/
        fi
        rm -rf ${src}
    fi
    if [[ ! -d ${src} ]];then
        ln -s ${dst} ${src}
    fi
}

function prepare_data_persist() {
    for app in jumpserver koko lion chen;do
        mv_dir_link /opt/$app/data /opt/data/${app}
    done
    
    mv_dir_link /var/log/nginx /opt/data/nginx
    mv_dir_link /var/lib/redis /opt/data/redis
    mv_dir_link /var/lib/postgresql /opt/data/postgresql
    chown postgres:postgres /var/lib/postgresql /opt/data/postgresql
}

function upgrade_db() {
    echo ">> Update database structure"
    cd /opt/jumpserver || exit 1
    ./jms upgrade_db || {
        echo -e "\033[31m Failed to change the table structure. \033[0m"
        exit 1
    }
}

export GIN_MODE=release

prepare_core
prepare_data_persist

# start other service
source ${cwd}/service.sh

until check tcp://${DB_HOST}:${DB_PORT}; do
    echo "wait for database ${DB_HOST} ready"
    sleep 2s
done

until check tcp://${REDIS_HOST}:${REDIS_PORT}; do
    echo "wait for redis ${REDIS_HOST} ready"
    sleep 2s
done

upgrade_db

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
