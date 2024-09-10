#!/bin/bash
#

version=v4.1.0

docker build --build-arg version=${version}-ce -t jumpserver/jms_all:${version} .