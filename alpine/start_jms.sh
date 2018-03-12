#!/bin/bash
#
set -x

make_migrations() {
  cd /opt/jumpserver/utils
  source /opt/py3/bin/activate
  while :;do
    if [ ! -f /opt/finish ]; then
      bash make_migrations.sh  && bash init_db.sh && touch /opt/finish
    else
      touch /opt/finish
      break
    fi
    sleep 1
  done
}

initial_DB(){
  while :;do
    if [ ! -f /opt/done ]; then
      if [[ -z "${DB_HOST}" ]]; then
        mysql -S /opt/mysql/mysql.sock -rfu root < /opt/mysql/mysql_security.sql && touch /opt/done
      else
        touch /opt/done
      fi
    else
      break
    fi
    sleep 1
  done
}



check_redis(){
  if [[ -z "${REDIS_HOST}" ]]; then
    cat << EOF >> /etc/supervisord.conf
[program:redis]
command=/usr/bin/redis-server
pidfile=/opt/redis.pid
autostart=true
autorestart=true

EOF
fi
}
check_mysql(){
  if [[ -z "${DB_HOST}" ]]; then
    mysql_install_db
    mkdir -p /opt/mysql/log /opt/mysql/data /opt/mysql/plugin
    chown mysql:mysql -R /opt/mysql
    if [[ -z "${DB_USER}" ]]; then
      DB_USER=jumpserver
    fi

    if [[ -z "${DB_PASSWORD}" ]]; then
      DB_PASSWORD=weakPassword
    fi

    sed -i 's/DB_USER/'${DB_USER}'/g' /opt/mysql/mysql_security.sql
    sed -i 's/DB_PASSWORD/'${DB_PASSWORD}'/g' /opt/mysql/mysql_security.sql

    cat << EOF >> /etc/supervisord.conf
[program:mariadb]
command=/usr/bin/mysqld_safe  --defaults-file=/etc/my.cnf
pidfile=/opt/mysqld.pid
user=mysql
redirect_stderr = true
autostart=true
autorestart=true

EOF
fi
}

mkdir -p /opt/nginx/log && chmod 777 /opt/nginx/log/

check_redis
check_mysql
/usr/bin/supervisord &
initial_DB
make_migrations

supervisord
