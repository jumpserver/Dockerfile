#!/bin/bash
#

/usr/bin/mysqld_safe --defaults-file=/etc/my.cnf &
mysql < /opt/mysql/mysql_security.sql
