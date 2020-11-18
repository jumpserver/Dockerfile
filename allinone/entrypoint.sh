#!/bin/bash
#

if [ $DB_HOST == 127.0.0.1 ]; then
    if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
        mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
        mysqld --daemonize --user=mysql
        sleep 5s
        mysql -uroot -e "create database jumpserver default charset 'utf8' collate 'utf8_bin'; grant all on jumpserver.* to 'jumpserver'@'127.0.0.1' identified by '$DB_PASSWORD'; flush privileges;"
    else
        mysqld --daemonize --user=mysql --defaults-file=/etc/my.cnf
    fi
fi

if [ $REDIS_HOST == 127.0.0.1 ]; then
    redis-server &
fi

if [ ! -f "/opt/jumpserver/config.yml" ]; then
    echo > /opt/jumpserver/config.yml
fi

if [ ! $WINDOWS_SKIP_ALL_MANUAL_PASSWORD ]; then
    export WINDOWS_SKIP_ALL_MANUAL_PASSWORD=True
fi

source /opt/py3/bin/activate
cd /opt/jumpserver && ./jms start -d
cd /opt/koko && ./koko -d
/etc/init.d/guacd start
sh /config/tomcat9/bin/startup.sh
/usr/sbin/nginx &

echo "Jumpserver ALL $Version"
tail -f /opt/readme.txt
