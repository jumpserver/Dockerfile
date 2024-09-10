#!/bin/bash
#
docker volume create jsdata &> /dev/null
docker run --name jms_all \
     -v jsdata:/opt/data \
     -p 8085:80 jumpserver/jms_all:v4.1.0 
