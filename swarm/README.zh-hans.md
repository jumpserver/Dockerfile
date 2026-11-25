# Docker Swarm 集群部署

[English](README.md) · 简体中文 · [繁體中文](README.zh-hant.md)

使用 Docker Swarm 编排 JumpServer 各组件，适合需要横向扩容、或已有容器基础设施的环境。

当前编排包含 Core、Celery、Chen、Koko、Web，不包含 Kael。

## 前置条件

- 已初始化 Docker Swarm 集群；
- 所有可能运行 JumpServer 服务的 Worker 节点挂载了同一份共享存储（NFS、GlusterFS、Ceph 等）；
- 自备数据库与 Redis：
  - 数据库：MariaDB `>= 10.6` 或 PostgreSQL `>= 13`；
  - Redis：`>= 6.2`；
- 图形会话与 guacd 均由 Koko 容器提供，使用 Koko 数据目录。

> [!NOTE]
> 从旧版本升级时，请移除 `.env` 中的 `GUA_HOST=guacd`，改用 Koko 默认的本地 guacd；如确实需要外置 guacd，可以继续保留该配置。

## 1. 准备共享存储

在**所有** Worker 节点挂载共享存储（示例使用 `config_example.conf` 中的默认值 `/opt/jumpserver`），并手动创建所需目录：

```sh
# 注意: Docker Swarm 模式不会自动创建挂载目录
mkdir -p /opt/jumpserver/core/data
mkdir -p /opt/jumpserver/chen/data
mkdir -p /opt/jumpserver/koko/data
mkdir -p /opt/jumpserver/web/data/logs
mkdir -p /opt/jumpserver/web/download
```

## 2. 准备配置文件

```sh
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile/swarm
cp config_example.conf .env
vi .env
```

需要重点确认的配置项：

| 配置 | 说明 |
| --- | --- |
| `VERSION` | 镜像版本，例如 `v5.0.0`，对应 `jumpserver/*:v5.0.0-ce` |
| `VOLUME_DIR` | 共享存储目录，需与第 1 步创建的目录一致 |
| `NETWORK_DRIVER` | Swarm 模式使用 `overlay` |
| `DB_HOST` / `DB_PORT` / `DB_USER` / `DB_PASSWORD` / `DB_NAME` | 自备数据库连接信息 |
| `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` | 自备 Redis 连接信息 |
| `SECRET_KEY` | 加密密钥，首次安装必须修改并牢记，后续升级和迁移不可更改 |
| `BOOTSTRAP_TOKEN` | 组件注册密钥，仅组件注册时使用（koko、chen 等） |
| `CORE_HOST` | 组件通信地址，默认 `http://core:8080` |
| `HTTP_PORT` / `SSH_PORT` | Web 与 SSH 对外端口 |
| `DOMAINS` | 对外访问域名，多个域名以逗号分隔 |

> [!IMPORTANT]
> `SECRET_KEY` 是保护签名数据的密钥，部署后不可更改，否则加密数据将无法解密；`BOOTSTRAP_TOKEN` 在重启、扩容时需保持一致，否则组件无法注册。

## 3. 生成 stack 文件

`docker-compose*.yml` 为 Compose 格式，需要转换成 Swarm 可用的 stack 文件：

```sh
docker compose -f docker-compose-network.yml -f docker-compose-init-db.yml config \
  | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack-init-db.yml

docker compose -f docker-compose-network.yml -f docker-compose.yml config \
  | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack.yml
```

## 4. 初始化数据库

```sh
docker stack deploy -c docker-stack-init-db.yml jumpserver
docker service ls
docker service ps jumpserver_init_db
```

根据 `docker service ps` 输出的节点，到对应 Worker 节点查看初始化日志，确认数据库结构升级完成。

## 5. 部署应用

```sh
docker stack deploy --prune -c docker-stack.yml jumpserver
docker service ls
```

`--prune` 会清理配置中已移除的组件服务。部署完成后访问 `http://<节点 IP>:<HTTP_PORT>/`。

## 运维

```sh
# 扩容 koko 到 2 个副本
docker service update --replicas=2 jumpserver_koko

# 查看服务日志
docker service logs -f jumpserver_core

# 更新镜像版本：修改 .env 中的 VERSION 后重新生成并部署
docker stack deploy --prune -c docker-stack.yml jumpserver

# 下线
docker stack rm jumpserver
```

> [!TIP]
> 内置的 `docker-compose-mariadb.yml` 与 `docker-compose-redis.yml` 可用于单机 Compose 场景快速准备数据库和缓存，Swarm 模式请使用自备的数据库与 Redis。

## 初始账号

- 用户名：`admin`
- 密码：`ChangeMe`
