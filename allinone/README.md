# Dockerfile

Jumpserver all in one Dockerfile

This project is Docker image build.

该项目是 Jumpserver 项目的 Docker 镜像生成代码

## How to start

环境迁移和更新升级请检查 SECRET_KEY 是否与之前设置一致, 不能随机生成, 否则数据库所有加密的字段均无法解密

### Quick start

仅在测试环境中快速部署验证功能使用, 生产环境请使用 [标准部署](https://github.com/jumpserver/Dockerfile)

```sh
docker network create jms_net --subnet=192.168.250.0/24

docker run --name jms_mysql --network jms_net -d \
  -e MARIADB_ROOT_PASSWORD=weakPassword \
  -e MARIADB_DATABASE=jumpserver \
  mariadb:10

docker run --name jms_all --network jms_net --rm \
  -e DB_HOST=jms_mysql \
  -e DB_USER=root \
  -e DB_PASSWORD=weakPassword \
  --privileged=true \
  jumpserver/jms_all:v2.20.2 init_db

docker run --name jms_all --network jms_net -d \
  -p 80:80 \
  -p 2222:2222 \
  -e LOG_LEVEL=ERROR \
  -e DB_HOST=jms_mysql \
  -e DB_USER=root \
  -e DB_PASSWORD=weakPassword \
  -e DB_NAME=jumpserver \
  --privileged=true \
  jumpserver/jms_all:v2.20.2
```
```sh
# 测试完毕后清理环境
docker stop jms_all
docker rm jms_all
docker stop jms_mysql
docker rm jms_mysql
docker volume prune -f
docker network prune -f
```

### Standard start

使用外置 MySQL 数据库和 Redis:

    - 外置数据库要求 MySQL 版本大于等于 5.7
    - 外置 Redis 要求 Redis 版本大于等于 6.0

```sh
# 自行部署 MySQL 可以参考 (https://docs.jumpserver.org/zh/master/install/setup_by_lb/#mysql)
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

    - SECRET_KEY = xxxxx                # 自行生成随机的字符串, 不要包含特殊字符串, 长度推荐大于等于 50
    - BOOTSTRAP_TOKEN = xxxxx           # 自行生成随机的字符串, 不要包含特殊字符串, 长度推荐大于等于 24
    - LOG_LEVEL = ERROR                 # 日志等级, 测试环境推荐设置为 DEBUG

    - DB_ENGINE = mysql                 # 使用 MySQL 数据库
    - DB_HOST = mysql_host              # MySQL 数据库 IP 地址
    - DB_PORT = 3306                    # MySQL 数据库 端口
    - DB_USER = xxx                     # MySQL 数据库认证用户
    - DB_PASSWORD = xxxx                # MySQL 数据库认证密码
    - DB_NAME = jumpserver              # JumpServer 使用的数据库名称

    - REDIS_HOST = redis_host           # 使用 Redis 缓存
    - REDIS_PORT = 6379                 # Redis 服务器 IP 地址
    - REDIS_PASSWORD = xxxx             # Redis 认证密码

    - VOLUME /opt/jumpserver/data       # Core 持久化目录, 存储录像日志
    - VOLUME /opt/koko/data             # Koko 持久化目录
    - VOLUME /opt/lion/data             # Lion 持久化目录

注意：自己上面设置的这些信息一定要记录下来。升级需要重新输入使用

**初始化数据库**
```bash
docker run --name jms_all --rm \
  -v /opt/jumpserver/core/data:/opt/jumpserver/data \
  -v /opt/jumpserver/koko/data:/opt/koko/data \
  -v /opt/jumpserver/lion/data:/opt/lion/data \
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
  jumpserver/jms_all:v2.20.2 init_db   # 确定无报错
```

**启动 JumpServer**
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
  jumpserver/jms_all:v2.20.2
```

**升级**
```bash
# 查询定义的 JumpServer 配置
docker exec -it jms_all env

# 停止 JumpServer
docker stop jms_all

# 备份数据库, 下面用到的 DB-xxx 从上面的 docker exec -it jms_all env 结果获取
mysqldump -h$DB_HOST -p$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME > /opt/jumpserver-<版本号>.sql
# 例: mysqldump -h192.168.100.11 -p3306 -ujumpserver -pnu4x599Wq7u0Bn8EABh3J91G jumpserver > /opt/jumpserver-v2.12.0.sql

# 拉取新版本镜像
docker pull jumpserver/jms_all:v2.20.2

# 删掉旧版本容器
docker rm jms_all

# 处理数据库合并
docker run --name jms_all --rm \
  -v /opt/jumpserver/core/data:/opt/jumpserver/data \
  -v /opt/jumpserver/koko/data:/opt/koko/data \
  -v /opt/jumpserver/lion/data:/opt/lion/data \
  -e SECRET_KEY=****** \                 # 自行修改成你的旧版本 SECRET_KEY, 丢失此 key 会导致数据无法解密
  -e BOOTSTRAP_TOKEN=****** \            # 自行修改成你的旧版本 BOOTSTRAP_TOKEN
  -e LOG_LEVEL=ERROR \
  -e DB_HOST=192.168.x.x \               # 自行修改成你的旧版本 MySQL 服务器, 设置不对数据丢失
  -e DB_PORT=3306 \
  -e DB_USER=jumpserver \
  -e DB_PASSWORD=****** \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \            # 自行修改成你的旧版本 Redis 服务器
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=****** \
  jumpserver/jms_all:v2.20.2 upgrade     # 确定无报错

# 启动新版本
docker run --name jms_all -d \
  -v /opt/jumpserver/core/data:/opt/jumpserver/data \
  -v /opt/jumpserver/koko/data:/opt/koko/data \
  -v /opt/jumpserver/lion/data:/opt/lion/data \
  -p 80:80 \
  -p 2222:2222 \
  -e SECRET_KEY=****** \                 # 自行修改成你的旧版本 SECRET_KEY, 丢失此 key 会导致数据无法解密
  -e BOOTSTRAP_TOKEN=****** \            # 自行修改成你的旧版本 BOOTSTRAP_TOKEN
  -e LOG_LEVEL=ERROR \
  -e DB_HOST=192.168.x.x \               # 自行修改成你的旧版本 MySQL 服务器, 设置不对数据丢失
  -e DB_PORT=3306 \
  -e DB_USER=jumpserver \
  -e DB_PASSWORD=****** \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \            # 自行修改成你的旧版本 Redis 服务器
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=****** \
  --privileged=true \
  jumpserver/jms_all:v2.20.2
```
