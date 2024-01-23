<p align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>
</p>
<h3 align="center">多云环境下更好用的堡垒机</h3>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
  <a href="https://hub.docker.com/u/jumpserver"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Codacy"></a>
  <a href="https://github.com/jumpserver/Dockerfile/commits"><img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/jumpserver/jumpserver.svg" /></a>
  <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="Stars"></a>
</p>

--------------------------

环境要求
- MariaDB Server >= 10.6
- Redis Server >= 6.0

快速部署
```sh
# 测试环境可以使用，生产环境推荐外置数据
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
docker-compose -f docker-compose-network.yml -f docker-compose-redis.yml -f docker-compose-mariadb.yml -f docker-compose-init-db.yml up -d
docker exec -i jms_core bash -c './jms upgrade_db'
docker-compose -f docker-compose-network.yml -f docker-compose-redis.yml -f docker-compose-mariadb.yml -f docker-compose.yml up -d
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
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
vi .env
```
```vim
# 版本号可以自己根据项目的版本修改
VERSION=v3.10.2

# 构建参数, 支持 amd64/arm64/loong64
TARGETARCH=amd64

# Compose
COMPOSE_PROJECT_NAME=jms
# COMPOSE_HTTP_TIMEOUT=3600
# DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=192.168.250.0/24

# 持久化存储
VOLUME_DIR=/opt/jumpserver

# MySQL, 修改为你的外置 **数据库** 地址
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=nu4x599Wq7u0Bn8EABh3J91G
DB_NAME=jumpserver

# Redis, 修改为你的外置 **Redis** 地址
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=8URXPL2x3HZMi7xoGTdk3Upj

# Core, 修改 SECRET_KEY 和 BOOTSTRAP_TOKEN
SECRET_KEY=B3f2w8P2PfxIAS7s4URrD9YmSbtqX4vXdPUL217kL9XPUOWrmy
BOOTSTRAP_TOKEN=7Q11Vz6R2J6BLAdO
DEBUG=FALSE
LOG_LEVEL=ERROR
DOMAINS=

# Web
HTTP_PORT=80
SSH_PORT=2222
MAGNUS_MYSQL_PORT=33061
MAGNUS_MARIADB_PORT=33062
MAGNUS_REDIS_PORT=63790

# Xpack
RDP_PORT=3389
MAGNUS_POSTGRESQL_PORT=54320
MAGNUS_ORACLE_PORTS=30000-30010

##
# SECRET_KEY 保护签名数据的密匙, 首次安装请一定要修改并牢记, 后续升级和迁移不可更改, 否则将导致加密的数据不可解密。
# BOOTSTRAP_TOKEN 为组件认证使用的密钥, 仅组件注册时使用。组件指 koko、lion、magnus 等。
```
```sh
docker-compose -f docker-compose-network.yml -f docker-compose-init-db.yml up -d
docker exec -i jms_core bash -c './jms upgrade_db'
docker-compose -f docker-compose-network.yml -f docker-compose.yml up -d
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
