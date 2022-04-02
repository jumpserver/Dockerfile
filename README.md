## Jumpserver Docker-Compose

- [JumpServer Allinone](https://github.com/jumpserver/Dockerfile/tree/master/allinone)

- 全面支持 arm64 国产化操作系统

系统架构
- [x] windows/amd64
- [x] windows/arm64
- [x] Linux/amd64
- [x] Linux/arm64
- [x] macOS/amd64
- [x] macOS/arm64

环境要求
- MySQL Server >= 5.7
- Redis Server >= 5.0

快速部署
```sh
# 测试环境可以使用，生产环境推荐外置数据
git clone --depth=1 https://github.com/wojiushixiaobai/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
docker-compose -f docker-compose-redis.yml -f docker-compose-mariadb.yml -f docker-compose.yml up
```

标准部署

> 请先自行创建 数据库 和 Redis, 版本要求参考上面环境要求说明

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

```sh
git clone --depth=1 https://github.com/wojiushixiaobai/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
vi .env
```
```vim
# 版本号可以自己根据项目的版本修改
Version=v2.20.2

# Compose
COMPOSE_PROJECT_NAME=jms
COMPOSE_HTTP_TIMEOUT=3600
DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=172.16.238.0/24

# 持久化存储
VOLUME_DIR=/opt/jumpserver

# MySQL  # 填写你的 Mysql 服务器信息
DB_HOST=192.168.100.11
DB_PORT=3306
DB_USER=jumpserver
DB_PASSWORD=nu4x599Wq7u0Bn8EABh3J91G
DB_NAME=jumpserver

# Redis  # 填写你的 Redis 服务器信息
REDIS_HOST=192.168.100.12
REDIS_PORT=6379
REDIS_PASSWORD=8URXPL2x3HZMi7xoGTdk3Upj

# Core
SECRET_KEY=B3f2w8P2PfxIAS7s4URrD9YmSbtqX4vXdPUL217kL9XPUOWrmy
BOOTSTRAP_TOKEN=7Q11Vz6R2J6BLAdO
DEBUG=FALSE
LOG_LEVEL=ERROR

##
# SECRET_KEY 保护签名数据的密匙, 首次安装请一定要修改并牢记, 后续升级和迁移不可更改, 否则将导致加密的数据不可解密。
# BOOTSTRAP_TOKEN 为组件认证使用的密钥, 仅组件注册时使用。组件指 koko、guacamole
```
```sh
docker-compose up
```

build
```sh
# 如果希望手动构建镜像, 可以使用下面的命令
cd Dockerfile
cp config_example.conf .env
vi .env
```
```vim
# 构建参数, 支持 amd64/arm64
TARGETARCH=amd64
```
```bash
docker-compose -f docker-compose-build.yml up
```
