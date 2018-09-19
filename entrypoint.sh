#!/bin/bash
#

redis-server &

source /opt/py3/bin/activate
cd /opt/jumpserver/utils
sh make_migrations.sh

cd /opt/jumpserver && ./jms start all -d
cd /opt/coco && ./cocod start -d

/usr/sbin/nginx

ping 127.0.0.1
