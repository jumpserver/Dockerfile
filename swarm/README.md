## 集群部署

- Docker Swarm 集群环境
- 自行创建 MySQL 和 Redis, 参考上面环境要求说明
- 自行创建持久化共享存储目录 ( 例如 NFS, GlusterFS, Ceph 等 )

```sh
# 在所有 Docker Swarm Worker 节点挂载 NFS 或者其他共享存储, 例如 /data/jumpserver
# 注意: 需要手动创建所有需要挂载的持久化目录, Docker Swarm 模式不会自动创建所需的目录
mkdir -p /data/jumpserver/core/data
mkdir -p /data/jumpserver/chen/data
mkdir -p /data/jumpserver/lion/data
mkdir -p /data/jumpserver/koko/data
mkdir -p /data/jumpserver/lion/data
mkdir -p /data/jumpserver/web/data/logs
mkdir -p /data/jumpserver/web/download
```
```sh
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile/swarm
cp config_example.conf .env
vi .env
```

```vim
# 版本号可以自己根据项目的版本修改
VERSION=v4.1.0

TARGETARCH=amd64

# Compose, Swarm 模式下修改 NETWORK_DRIVER=overlay
COMPOSE_PROJECT_NAME=jms
# COMPOSE_HTTP_TIMEOUT=3600
# DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=192.168.250.0/24
NETWORK_DRIVER=overlay

# 持久化存储
VOLUME_DIR=/opt/jumpserver

# 时区
TZ=Asia/Shanghai

# MySQL
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=nu4x599Wq7u0Bn8EABh3J91G
DB_NAME=jumpserver

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=8URXPL2x3HZMi7xoGTdk3Upj

# Core
SECRET_KEY=B3f2w8P2PfxIAS7s4URrD9YmSbtqX4vXdPUL217kL9XPUOWrmy
BOOTSTRAP_TOKEN=7Q11Vz6R2J6BLAdO
LOG_LEVEL=ERROR
DOMAINS=

# 组件通信
CORE_HOST=http://core:8080

# Lion
GUACD_LOG_LEVEL=error
GUA_HOST=guacd
GUA_PORT=4822

# Web
HTTP_PORT=80
SSH_PORT=2222

##
# SECRET_KEY 保护签名数据的密匙, 首次安装请一定要修改并牢记, 后续升级和迁移不可更改, 否则将导致加密的数据不可解密。
# BOOTSTRAP_TOKEN 为组件认证使用的密钥, 仅组件注册时使用。组件指 koko, lion, magnus, kael, chen ...
```
```sh
# 生成 docker stack 部署所需文件
docker compose -f docker-compose-network.yml -f docker-compose-init-db.yml config | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack-init-db.yml
docker compose -f docker-compose-network.yml -f docker-compose.yml config | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack.yml
```
```sh
# 初始化数据库
docker stack deploy -c docker-stack-init-db.yml jumpserver
docker service ls
docker service ps jumpserver_init_db
 
# 根据查到的 Worker 节点, 到对应节点查看初始化日志
```
```sh
# 启动 JumpServer 应用
docker stack deploy -c docker-stack.yml jumpserver
docker service ls
```
```sh
# 扩容缩容
docker service update --replicas=2 jumpserver_koko  # 扩容 koko 到 2 个副本
docker service update --replicas=4 jumpserver_lion  # 扩容 lion 到 2 个副本
# ...
```


## 初始账号
- 默认账号: `admin`
- 默认密码: `ChangeMe`