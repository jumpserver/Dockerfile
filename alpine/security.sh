#!/bin/bash
# coding: utf-8
# Copyright (c) 2018
# Gmail: liuzheng712
#

set -x

mysql -S /opt/mysql/mysql.sock -sfu root < /opt/mysql/mysql_security.sql
cd /opt/jumpserver-master/utils
source /opt/py3/bin/activate
bash make_migrations.sh && echo "SUCCESS"

