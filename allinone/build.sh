#!/bin/bash
#

version=dev

docker build --build-arg version=${version}-ce -t jumpserver/jms_all:${version} .