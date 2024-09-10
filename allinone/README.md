# Dockerfile

JumpServer all-in-one Dockerfile，该项目是 JumpServer all-in-one 部署方式的 Docker 镜像生成代码。

## How to start

环境迁移和更新升级请检查 SECRET_KEY 是否与之前设置一致, 不能随机生成, 否则数据库所有加密的字段均无法解密。

### Quick start

**注意: all-in-one 部署方式不支持 Client 相关功能, 仅支持在 纯 B/S 架构 Web 端使用。**

```sh
docker volume create jsdata
docker run --name jms_all \
     -e SECRET_KEY=PleaseChangeMe \
     -e BOOTSTRAP_TOKEN=PleaseChangeMe \
     -v jsdata:/opt/data \
     -p 2222:2222 \
     -p 80:80 jumpserver/jms_all
```

### 外置数据库

使用外置 MySQL 数据库和 Redis:

  - 外置数据库要求 MariaDB 版本大于等于 10.6 或者 PosgresSQL 13；
  - 外置 Redis 要求 Redis 版本大于等于 6.2。

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
    - VOLUME /opt/chen/data             # Chen 持久化目录
    - VOLUME /var/log/nginx             # Nginx 日志持久化目录
    - VOLUME /opt/download              # APPLETS 文件持久化目录 (应用发布机所需文件)

注意：自己上面设置的这些信息一定要记录下来，升级需要重新输入使用。

**启动 JumpServer**
```bash
docker volume create jsdata

docker run --name jms_all -d \
  -p 80:80 \
  -p 2222:2222 \
  -e SECRET_KEY=xxxxxx \
  -e BOOTSTRAP_TOKEN=xxxxxx \
  -e LOG_LEVEL=INFO \
  -e DB_HOST=192.168.x.x \
  -e DB_PORT=3306 \
  -e DB_USER=jumpserver \
  -e DB_PASSWORD=weakPassword \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=weakPassword \
  --privileged=true \
  -v jsdata:/opt/data \
  jumpserver/jms_all:v4.1.0
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
docker pull jumpserver/jms_all:v4.1.0

# 删掉旧版本容器
docker rm jms_all

# 重新启动新版本
```

**初始账号**
```bash
默认账号: admin
默认密码: ChangeMe
```