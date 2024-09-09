#!/bin/bash
#
docker volume create pgdata &> /dev/null
docker run --name one --rm  -v pgdata:/var/lib/postgresql/ -e DOMAINS=localhost:8085,jumpserver-test.fit2cloud.com:8085 -p 8085:80 -p 8086:8080 allinone
