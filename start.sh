#!/bin/bash
# coding: utf-8
# Copyright (c) 2018
# Gmail: liuzheng712
#

set -x

/usr/bin/supervisord &

cd /opt/jumpserver-master/utils
source /opt/py3/bin/activate

while :
do
  if [ ! -f /opt/done ]; then
    mysql -S /opt/mysql/mysql.sock -sfu root < /opt/mysql/mysql_security.sql && \
      touch /opt/done
    sleep 1
  else
    break
  fi
done

while :
do
  if [ ! -f /opt/finished ]; then
    bash make_migrations.sh && \
      touch /opt/finished 
    sleep 1
  else
    break
  fi
done

while :
do 
  sleep 2000
done
