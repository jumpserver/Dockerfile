<p align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>
</p>
<h3 align="center">A better bastion host for multi-cloud environments</h3>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
  <a href="https://hub.docker.com/u/jumpserver"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Codacy"></a>
  <a href="https://github.com/jumpserver/Dockerfile/commits"><img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/jumpserver/Dockerfile.svg" /></a>
  <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="Stars"></a>
</p>

--------------------------

## Environment Requirements
- MariaDB Server >= 10.6
- Redis Server >= 6.0

## Quick Deployment
```sh
# Suitable for testing environment, for production environment, it is recommended to use external data
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
docker compose -f docker-compose-network.yml -f docker-compose-redis.yml -f docker-compose-mariadb.yml -f docker-compose-init-db.yml up -d
docker compose -f docker-compose-network.yml -f docker-compose-redis.yml -f docker-compose-mariadb.yml -f docker-compose.yml up -d

docker rm jms_init_db
```

## Standard Deployment

> Please create the database and Redis yourself first, the version requirements refer to the above environment requirements

```sh
# For deploying MySQL yourself, you can refer to (https://docs.jumpserver.org/zh/master/install/setup_by_lb/#mysql)
# Create a MySQL user and grant permissions, please replace nu4x599Wq7u0Bn8EABh3J91G with your own password
mysql -u root -p
```

```mysql
create database jumpserver default charset 'utf8';
create user 'jumpserver'@'%' identified by 'nu4x599Wq7u0Bn8EABh3J91G';
grant all on jumpserver.* to 'jumpserver'@'%';
flush privileges;
```

```sh
# For deploying Redis yourself, you can refer to (https://docs.jumpserver.org/zh/master/install/setup_by_lb/#redis).
```

```sh
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
vi .env
```
```vim
# You can modify the version number according to the project version
VERSION=v3.10.11

# Build parameters, support amd64, arm64, ppc64le, s390x
TARGETARCH=amd64

# For Compose, Swarm mode, modify NETWORK_DRIVER=overlay
COMPOSE_PROJECT_NAME=jms
# COMPOSE_HTTP_TIMEOUT=3600
# DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=192.168.250.0/24
NETWORK_DRIVER=bridge

# Persistent storage
VOLUME_DIR=/opt/jumpserver

# Time zone
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

# Lion
GUA_HOST=guacd
GUA_PORT=4822

# Web
HTTP_PORT=80
SSH_PORT=2222

##
# SECRET_KEY is the key to protect signed data. Please be sure to modify and remember it for the first installation. It cannot be changed during subsequent upgrades and migrations, otherwise the encrypted data will not be decrypted.
# BOOTSTRAP_TOKEN is the key used for component authentication, only used when the component is registered. The components refer to koko, lion, magnus, kael, chen ...
```
```sh
docker compose -f docker-compose-network.yml -f docker-compose-init-db.yml up -d
docker compose -f docker-compose-network.yml -f docker-compose.yml up -d

docker rm jms_init_db
```

## Cluster Deployment

- Docker Swarm cluster environment
- Create MySQL and Redis yourself, refer to the above environment requirements
- Create a persistent shared storage directory yourself (such as NFS, GlusterFS, Ceph, etc.)

```sh
# Mount NFS or other shared storage on all Docker Swarm Worker nodes, such as /data/jumpserver
# Note: You need to manually create all the persistent directories that need to be mounted, Docker Swarm mode will not automatically create the required directories
mkdir -p /data/jumpserver/core/data
mkdir -p /data/jumpserver/chen/data
mkdir -p /data/jumpserver/lion/data
mkdir -p /data/jumpserver/kael/data
mkdir -p /data/jumpserver/koko/data
mkdir -p /data/jumpserver/lion/data
mkdir -p /data/jumpserver/magnus/data
mkdir -p /data/jumpserver/web/data/logs
mkdir -p /data/jumpserver/web/download
```
```sh
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cp config_example.conf .env
vi .env
```
```vim
# The version number can be modified according to the version of the project
VERSION=v3.10.10

# Build parameters, support amd64, arm64, ppc64le, s390x
TARGETARCH=amd64

# For Compose, Swarm mode, modify NETWORK_DRIVER=overlay
COMPOSE_PROJECT_NAME=jms
# COMPOSE_HTTP_TIMEOUT=3600
# DOCKER_CLIENT_TIMEOUT=3600
DOCKER_SUBNET=192.168.250.0/24
NETWORK_DRIVER=overlay

# Persistent storage
VOLUME_DIR=/opt/jumpserver

# Time zone
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

# Lion
GUA_HOST=guacd
GUA_PORT=4822

# Web
HTTP_PORT=80
SSH_PORT=2222

##
# SECRET_KEY is the key to protect signed data. Please be sure to modify and remember it for the first installation. It cannot be changed during subsequent upgrades and migrations, otherwise the encrypted data will not be decrypted.
# BOOTSTRAP_TOKEN is the key used for component authentication, only used when the component is registered. The components refer to koko, lion, magnus, kael, chen ...
```
```sh
# Generate files required for docker stack deployment
docker compose -f docker-compose-network.yml -f docker-compose-init-db.yml config | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack-init-db.yml
docker compose -f docker-compose-network.yml -f docker-compose.yml config | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack.yml
```
```sh
# Initialize the database
docker stack deploy -c docker-stack-init-db.yml jumpserver
docker service ls
docker service ps jumpserver_init_db
 
# According to the found Worker node, check the initialization log on the corresponding node
```
```sh
# Start JumpServer application
docker stack deploy -c docker-stack.yml jumpserver
docker service ls
```
```sh
# Scale up and down
docker service update --replicas=2 jumpserver_koko  # Scale up koko to 2 replicas
docker service update --replicas=4 jumpserver_lion  # Scale up lion to 2 replicas
# ...
```

## Build
```vim
# Build parameters, support amd64/arm64
TARGETARCH=amd64
```
```sh
docker compose -f docker-compose-build.yml up
```