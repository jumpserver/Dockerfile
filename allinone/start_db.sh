#!/bin/bash
#

function init_pg() {
    DB_NAME=${DB_NAME-jumpserver}
    POSTGRES_PASSWORD=${DB_PASSWORD-PleaseChangeMe}

    sed -i s'@DB_USER: .*@DB_USER: postgres@g' /opt/jumpserver/config.yml

    if [[ -f /var/lib/postgresql/13/main/inited.txt ]];then
        return
    fi
    
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$POSTGRES_PASSWORD';"
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;"
}


echo "Start database postgre"
pg_ctlcluster 13 main start

echo "Start redis server"
/usr/bin/redis-server /etc/redis/redis.conf --requirepass $REDIS_PASSWORD

init_pg && touch /var/lib/postgresql/13/main/inited.txt
