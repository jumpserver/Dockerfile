#!/bin/bash
#
docker volume create jsdata &> /dev/null
docker run --name jumpserver \
     -v jsdata:/opt/data \
     -e DOMAINS=localhost:8085,jumpserver-test.fit2cloud.com:8085  \
     -p 8085:80 \
     -p 8086:8080 jumpserver/jms_all
