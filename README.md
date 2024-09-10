<p align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>
</p>
<h3 align="center">多云环境下更好用的堡垒机</h3>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
  <a href="https://hub.docker.com/u/jumpserver"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Codacy"></a>
  <a href="https://github.com/jumpserver/Dockerfile/commits"><img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/jumpserver/Dockerfile.svg" /></a>
  <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="Stars"></a>
</p>

--------------------------

## 环境要求
- PostgreSQL >= 13 或 MariaDB Server >= 10.6 
- Redis Server >= 6.0

## 快速部署
```sh
# 测试环境可以使用，生产环境推荐外置数据
docker volume create jsdata
docker run --name jms_all \
     -v jsdata:/opt/data \
     -p 2222:2222 \
     -p 80:80 jumpserver/jms_all
```

更多 详见 allinone 目录 README

## 标准部署

请使用 jumpserver installer 部署

https://docs.jumpserver.org/zh/v3/quick_start/


## 集群部署

JumpServer 支持 swarm 方式部署，但目前不太推荐用于生产环境，除非你对此熟悉 
见 swarm 目录 README
