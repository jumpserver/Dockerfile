#!/bin/bash
#

function init_pg() {
    echo ">> Init database"
    DB_NAME=${DB_NAME:-jumpserver}
    DB_PASSWORD=${DB_PASSWORD:-PleaseChangeMe}
    DB_ENGINE=${DB_ENGINE:-postgresql}
    DB_HOST=${DB_HOST:-127.0.0.1}
    DB_PORT=${DB_PORT:-5432}
    DB_USER=${DB_USER:-postgres}

    export DB_NAME DB_PASSWORD DB_ENGINE DB_HOST DB_PORT DB_USER
    if [[ ${DB_HOST} != "127.0.0.1" ]];then
        echo "External database skip start, ${DB_HOST}"
        return
    fi

    PG_CLUSTER_INFO=$(pg_lsclusters --no-header | awk 'NR==1')
    if [[ -z "$PG_CLUSTER_INFO" ]]; then
        echo "No PostgreSQL cluster found"
        return 1
    fi

    PG_VERSION=$(echo "$PG_CLUSTER_INFO" | awk '{print $1}')
    PG_CLUSTER=$(echo "$PG_CLUSTER_INFO" | awk '{print $2}')
    PG_DATA_DIR=$(echo "$PG_CLUSTER_INFO" | awk '{print $6}')

    echo ">> Start database postgre"
    chown -R postgres:postgres ${PG_DATA_DIR}
    pg_ctlcluster ${PG_VERSION} ${PG_CLUSTER} start
    sleep 3
    
    if [[ ! -f ${PG_DATA_DIR}/inited.txt ]];then
        sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$DB_PASSWORD';"
        sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
        touch ${PG_DATA_DIR}/inited.txt
    fi 
}

function init_ng(){
    echo ">> Init nginx"
    echo """
127.0.0.1 core 
127.0.0.1 koko
127.0.0.1 chen
    """ >> /etc/hosts
    mkdir -p /var/log/nginx
    mkdir -p /var/cache/nginx
}

function init_redis() {
    REDIS_HOST=${REDIS_HOST:-127.0.0.1}
    REDIS_PORT=${REDIS_PORT:-6379}
    REDIS_PASSWORD=${REDIS_PASSWORD:-PleaseChangeMe}
    export REDIS_HOST REDIS_PORT REDIS_PASSWORD

    if [[ ${REDIS_HOST} != '127.0.0.1' ]];then
        echo "External redis server skip start, ${REDIS_HOST}"
        return
    fi

    echo ">> Start redis server"
    /usr/bin/redis-server /etc/redis/redis.conf --requirepass $REDIS_PASSWORD
}

function init_other() {
    # chen
    sed -i "s@root: INFO@root: ${LOG_LEVEL}@g" /opt/chen/config/application.yml

    # cron
    if [ -f "/etc/init.d/cron" ]; then
      /etc/init.d/cron start
    fi

}


init_pg 
init_ng
init_redis
init_other

