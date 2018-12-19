#!/bin/bash
#

export LANG=zh_CN.UTF-8

if [ $DB_HOST == 127.0.0.1 ]; then
    mysqld_safe &
fi

if [ $REDIS_HOST == 127.0.0.1 ]; then
    redis-server &
fi

source /opt/py3/bin/activate

function make_migrations(){
    cd /opt/jumpserver/utils
    sh make_migrations.sh
}

function make_migrations_if_need(){
    sentinel=/opt/jumpserver/data/inited

    if [ -f ${sentinel} ];then
        echo "Database have been inited"
    else
        make_migrations && echo "Database init success" && touch $sentinel
    fi
}

function start() {
    make_migrations_if_need
}

case $1 in
    init) make_migrations;;
    *) start;;
esac

cd /opt/jumpserver && ./jms start all -d
/usr/sbin/nginx &
/etc/init.d/guacd start
sh /config/tomcat8/bin/startup.sh
cd /opt/coco && ./cocod start -d
tail -f /opt/readme.txt
