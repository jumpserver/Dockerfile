#!/bin/bash
#
docker volume create jsdata &> /dev/null
docker run --name jumpserver \
     -v jsdata:/opt/data \
     -p 80:80 jumpserver/jms_all
