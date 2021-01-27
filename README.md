# 说明
从 v2.6 开始 Dockerfile 不再维护，它的工作由 https://github.com/jumpserver/installer 来完成，installer 统一了社区和企业版的安装，并且可以做到无缝迁移

## Jumpserver Docker-Compose

```sh
git clone https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
vi .env
docker-compose up
```

build
```sh
cd Dockerfile
cp config_example.conf .env
vi .env  # 修改配置
docker-compose -f docker-compose-build.yml up
```
## 说明

- .env 的变量 用在 docker-compose 里面, 可以自己看下
可能还有一些未能检测到的问题, 尽量自己调试一遍后再使用

> 如果自己编译, 可以在 docker-compose 的 environment: 处加入 Version: $Version , 取代 Dockerfile 的 ARG

## 外置 数据库 和 redis

- REDIS >= 5.0
- MySQL >= 5.7
- MariaDB >= 10.2

```mysql
create database jumpserver default charset 'utf8' collate 'utf8_bin';
grant all on jumpserver.* to 'jumpserver'@'%' identified by 'weakPassword';
```

- 然后在 .env 里面定义 mysql 和 redis

```sh
cd Dockerfile
cp config_example.conf .env
vi .env
docker-compose -f docker-compose-external.yml up
```
