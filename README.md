# Dockerfile

Jumpserver all in one Dockerfile

This project is only for Docker image build, this docker image we do not suggest you build in a product environment.

该项目仅仅是Jumpserver项目的docker镜像生成代码，我们不建议在生产环境下使用该镜像。

The main reasons are:

   - the database is in the docker too, and we suggest you use your own database by docker env.
   - lack of scalability
   - NO HA plan
   - some unknown problems

主要原因是：

   - 数据库在docker内，建议通过docker的环境变量去使用外部数据库
   - 几乎丧失的横向扩展能力
   - 没有HA的解决方案
   - 未知的一些问题

## How to start


```bash
SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`  # 生成加密秘钥, 勿外泄
BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`  # 生成组件注册所需Token, 勿外泄

docker run --name jms_all -dp 80:80 -p 2222:2222 -e SECRET_KEY=$SECRET_KEY -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN jumpserver/jms_all:latest

```

环境迁移和更新升级请手动指定SECRET_KEY和BOOTSTRAP_TOKEN, 需要保持一致

使用外置mysql数据库和redis:

**设置环境变量：**

- SECRET_KEY = xxxxx
- BOOTSTRAP_TOKEN = xxxxx

- DB_ENGINE = mysql
- DB_HOST = mysql_host
- DB_PORT = 3306
- DB_USER = xxx
- DB_PASSWORD = xxxx
- DB_NAME = jumpserver

- REDIS_HOST = 127.0.0.1
- REDIS_PORT = 3306
- REDIS_PASSWORD =

- JUMPSERVER_KEY_DIR=/config/guacamole/keys \
- GUACAMOLE_HOME=/config/guacamole \
- JUMPSERVER_SERVER=http://127.0.0.1:8080

- VOLUME /opt/jumpserver/data/media
- VOLUME /var/lib/mysql


```bash
docker run --name jms_all -d \
  -v /opt/jumpserver:/opt/jumpserver/data/media
  -v /opt/mysql:/var/lib/mysql
  -p 80:80 \
  -p 2222:2222 \
  -e SECRET_KEY=xxxxxx \
  -e BOOTSTRAP_TOKEN=xxxxxx \
  -e DB_ENGINE=mysql \
  -e DB_HOST=192.168.x.x \
  -e DB_PORT=3306 \
  -e DB_USER=root \
  -e DB_PASSWORD=xxx \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=password \
  jumpserver/jms:latest

```
