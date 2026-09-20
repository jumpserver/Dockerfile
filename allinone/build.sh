#!/bin/bash
#

version=v5.0.0

docker build --platform linux/amd64 --build-arg version=${version}-ce -t jumpserver/jms_all:${version} .
