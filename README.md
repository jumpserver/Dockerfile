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
    # 生成随机加密秘钥, 勿外泄
    $ if [ "$SECRET_KEY" = "" ]; then SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`; echo "SECRET_KEY=$SECRET_KEY" >> ~/.bashrc; echo $SECRET_KEY; else echo $SECRET_KEY; fi
    $ if [ "$BOOTSTRAP_TOKEN" = "" ]; then BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`; echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bashrc; echo $BOOTSTRAP_TOKEN; else echo $BOOTSTRAP_TOKEN; fi

    $ docker run --name jms_all -d -p 80:80 -p 2222:2222 -e SECRET_KEY=$SECRET_KEY -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN jumpserver/jms_all:latest

    # macOS 生成随机 key 可以用下面的命令
    $ if [ "$SECRET_KEY" = "" ]; then SECRET_KEY=`LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 50`; echo "SECRET_KEY=$SECRET_KEY" >> ~/.bash_profile; echo $SECRET_KEY; else echo $SECRET_KEY; fi
    $ if [ "$BOOTSTRAP_TOKEN" = "" ]; then BOOTSTRAP_TOKEN=`LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 16`; echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bash_profile; echo $BOOTSTRAP_TOKEN; else echo $BOOTSTRAP_TOKEN; fi
```

环境迁移和更新升级请检查 SECRET_KEY 是否与之前设置一致, 不能随机生成, 否则数据库所有加密的字段均无法解密

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
  -v /opt/jumpserver/media:/opt/jumpserver/data/media \
  -v /opt/jumpserver/mysql:/var/lib/mysql \
  -p 80:80 \
  -p 2222:2222 \
  -e SECRET_KEY=xxxxxx \
  -e BOOTSTRAP_TOKEN=xxxxxx \
  -e DB_HOST=192.168.x.x \
  -e DB_PORT=3306 \
  -e DB_USER=root \
  -e DB_PASSWORD=xxx \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=password \
  jumpserver/jms_all:latest

```
