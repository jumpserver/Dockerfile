# Dockerfile

Jumpserver all in one Dockerfile

This project is Docker image build.

该项目是 Jumpserver 项目的 Docker 镜像生成代码

## How to start

环境迁移和更新升级请检查 SECRET_KEY 是否与之前设置一致, 不能随机生成, 否则数据库所有加密的字段均无法解密

使用外置 MySQL 数据库和 Redis:

    - 外置数据库要求 MySQL 版本大于等于 5.7
    - 外置 Redis 要求 Redis 版本大于等于 6.0


```sh
# mysql 创建数据库, 自行部署 MySQL 可以参考 (https://docs.jumpserver.org/zh/master/install/setup_by_lb/#mysql)
# mysql 创建用户并赋予权限, 请自行替换 nu4x599Wq7u0Bn8EABh3J91G 为自己的密码
mysql -u root -p
```

```mysql
create database jumpserver default charset 'utf8';
create user 'jumpserver'@'%' identified by 'nu4x599Wq7u0Bn8EABh3J91G';
grant all on jumpserver.* to 'jumpserver'@'%';
flush privileges;
```

```sh
# 自行部署 Redis 可以参考 (https://docs.jumpserver.org/zh/master/install/setup_by_lb/#redis)
```

**设置环境变量：**

    - SECRET_KEY = xxxxx
    - BOOTSTRAP_TOKEN = xxxxx
    - LOG_LEVEL = ERROR

    - DB_ENGINE = mysql
    - DB_HOST = mysql_host
    - DB_PORT = 3306
    - DB_USER = xxx
    - DB_PASSWORD = xxxx
    - DB_NAME = jumpserver

    - REDIS_HOST = redis_host
    - REDIS_PORT = 6379
    - REDIS_PASSWORD = xxxx

    - VOLUME /opt/jumpserver/data
    - VOLUME /opt/koko/data
    - VOLUME /opt/lion/data


```bash
docker run --name jms_all -d \
  -v /opt/jumpserver/core/data:/opt/jumpserver/data \
  -v /opt/jumpserver/koko/data:/opt/koko/data \
  -v /opt/jumpserver/lion/data:/opt/lion/data \
  -p 80:80 \
  -p 2222:2222 \
  -e SECRET_KEY=xxxxxx \
  -e BOOTSTRAP_TOKEN=xxxxxx \
  -e LOG_LEVEL=ERROR \
  -e DB_HOST=192.168.x.x \
  -e DB_PORT=3306 \
  -e DB_USER=jumpserver \
  -e DB_PASSWORD=weakPassword \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=weakPassword \
  --privileged=true \
  jumpserver/jms_all:v2.12.1
```
