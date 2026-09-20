#!/bin/bash
#

version=v5.0.0

docker build --build-arg version=${version}-ce -t jumpserver/jms_all:${version} .