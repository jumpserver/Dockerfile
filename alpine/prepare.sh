#!/bin/env bash
# coding: utf-8
# Copyright (c) 2018
# Gmail: liuzheng712
#

set -ex

source require.txt

if [ ! -f ${Python_dist} ]; then
  wget ${Python_URL} -O ${Python_dist}
fi


if [ ! -f ${Jumpserver_dist} ]; then
  wget ${Jumpserver_URL} -O ${Jumpserver_dist}
fi

if [ ! -f ${Coco_dist} ]; then
  wget ${Coco_URL} -O ${Coco_dist}
fi

if [ ! -f ${Luna_dist} ]; then
  wget ${Luna_URL} -O ${Luna_dist}
fi
