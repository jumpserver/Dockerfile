#!/bin/bash
#

make_migrations() {
    set -x
    cd /opt/jumpserver/utils
    source /opt/py3/bin/activate
    bash make_migrations.sh && echo "SUCCESS"
}


start() {
    while :;do
        make_migrations
        if [ $? == 0 ];then
            break
        else
            echo "Wait for next time for migrations"
            sleep 1
        fi
    done
    source /opt/py3/bin/activate && python /opt/jumpserver/run_server.py all
}


start

