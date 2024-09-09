#!/bin/bash
#

function init_pg() {
    echo "Init database"
    DB_NAME=${DB_NAME-jumpserver}
    POSTGRES_PASSWORD=${DB_PASSWORD-PleaseChangeMe}

    sed -i s'@DB_USER: .*@DB_USER: postgres@g' /opt/jumpserver/config.yml

    if [[ -f /var/lib/postgresql/13/main/inited.txt ]];then
        return
    fi
    
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRES_PASSWORD';"
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
}

function init_ng(){
    echo "Init nginx"
    echo """
    127.0.0.1 core 
    127.0.0.1 koko
    127.0.0.1 lion
    127.0.0.1 chen
    """ >> /etc/hosts
    mkdir -p /var/log/nginx
    mkdir -p /var/cache/nginx

    /docker-entrypoint.d/40-init-config.sh
}

echo "Start database postgre"
chown postgres /var/lib/postgresql/13/main
pg_ctlcluster 13 main start

echo "Start redis server"
/usr/bin/redis-server /etc/redis/redis.conf --requirepass $REDIS_PASSWORD

init_pg && touch /var/lib/postgresql/13/main/inited.txt
init_ng

