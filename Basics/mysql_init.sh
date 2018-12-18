#!/bin/bash

set -e

mysqld_safe &

sleep 5s

mysql -uroot -e "
create database jumpserver default charset 'utf8';
grant all on jumpserver.* to 'jumpserver'@'127.0.0.1' identified by 'weakPassword';
flush privileges;"

exit 0
