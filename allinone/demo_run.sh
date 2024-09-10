#!/bin/bash
#
docker volume create jsdata &> /dev/null
docker volume create pgdata &> /dev/null
docker run --name jms_all \
     -v jsdata:/opt/data \
     -v pgdata:/var/lib/postgresql \
     -p 8085:80 jumpserver/jms_all:dev
