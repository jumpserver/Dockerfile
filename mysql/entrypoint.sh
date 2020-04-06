#!/bin/bash
#

function config_mysql {
    if [ $DB_PORT != 3306 ]; then
        if [ ! "$(cat /etc/my.cnf | grep port=)" ]; then
            sed -i "10i port=$DB_PORT" /etc/my.cnf
        else
            sed -i "s/port=.*/port=$DB_PORT/g" /etc/my.cnf
        fi
    fi
}

if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
    config_mysql
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --force
    mysqld_safe &
    sleep 5s
    mysql -uroot -e "create database $DB_NAME default charset 'utf8';grant all on $DB_NAME.* to '$DB_USER'@'%' identified by '$DB_PASSWORD';flush privileges;";
    mysql --version
    tail -f /var/log/mariadb/mariadb.log
else
    config_mysql
    mysql --version
    mysqld_safe
fi
