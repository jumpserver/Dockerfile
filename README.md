## Jumpserver Docker-Compose

- 全面支持 arm64 国产化操作系统

系统架构
- [x] Linux/amd64
- [x] Linux/arm64

环境要求
- MySQL Server >= 5.7
- Redis Server >= 6.0

> 请先自行创建 数据库 和 Redis, 版本要求参考上面环境要求说明

```sh
git clone --depth=1 https://github.com/wojiushixiaobai/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
vi .env
```
```vim
# 版本号可以自己根据项目的版本修改
Version=v2.11.3

# Compose
COMPOSE_PROJECT_NAME=jms
COMPOSE_HTTP_TIMEOUT=3600
DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=172.16.238.0/24

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
