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
cd /opt/jumpserver && ./jms start all -d
/usr/sbin/nginx &
/etc/init.d/guacd start
sh /config/tomcat8/bin/startup.sh
cd /opt/coco && ./cocod start -d
tail -f /opt/readme.txt
