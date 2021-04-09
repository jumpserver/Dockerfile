## Jumpserver Docker-Compose

环境要求
- MySQL Server >= 5.7
- Redis Server >= 5.0

> 请先自行创建 数据库 和 Redis, 版本要求参考上面环境要求说明

```sh
git clone --depth=1 https://github.com/wojiushixiaobai/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
vi .env
```
```vim
# 版本号可以自己根据项目的版本修改
Version=v2.8.3

# Network
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
docker-compose -f docker-compose-build.yml up
```

> 如果自己编译, 可以在 docker-compose 的 environment: 处加入 Version: $Version , 取代 Dockerfile 的 ARG
