# JumpServer all-in-one

[English](README.md) · 简体中文 · [繁體中文](README.zh-hant.md)

JumpServer all-in-one 部署方式的镜像构建与运行文件。单个容器内运行 Core、Koko、Chen、Kael、Web，并内置 PostgreSQL 与 Redis，适合快速体验、测试和小规模部署。

> [!NOTE]
> all-in-one 不支持 Client 相关功能，仅支持纯 B/S 架构的 Web 端使用。生产环境请使用 [JumpServer 安装包](https://docs.jumpserver.org/zh/v3/quick_start/) 进行标准部署。

## 镜像内容

| 组件 | 说明 | 端口 / 入口 |
| --- | --- | --- |
| Core | JumpServer 核心 API 与调度服务 | 容器内 `8080` |
| Web | Nginx 前端与反向代理 | `80` |
| Koko | 字符协议连接器；镜像内置 guacd，提供图形会话 | `2222`，Web 入口 `/koko/lion/` |
| Chen | Web 数据库连接器 | Web 入口 `/chen/` |
| Kael | AI 服务，复用 `BOOTSTRAP_TOKEN` 注册组件 | Web 入口 `/kael/` |
| PostgreSQL | 内置数据库，支持切换为外置 MySQL/PostgreSQL | `5432` |
| Redis | 内置缓存，支持切换为外置 Redis | `6379` |

PostgreSQL 与 Redis 由入口脚本启动，其余服务由 Supervisor 拉起并在异常退出后自动重启。

## 前置条件

- 已安装 Docker，镜像仅提供 `linux/amd64` 版本；
- 宿主机需可访问 Docker Hub（或已提前拉取镜像）；
- 首次启动会初始化数据库并执行 `upgrade_db`，耗时取决于机器性能。

## 快速开始

使用内置 PostgreSQL 与 Redis 启动：

```sh
docker volume create jsdata
docker volume create pgdata

docker run -d --name jms_all \
  -e SECRET_KEY=[API_KEY] \
  -e BOOTSTRAP_TOKEN=PleaseChangeMe \
  -v jsdata:/opt/data \
  -v pgdata:/var/lib/postgresql \
  -p 80:80 \
  -p 2222:2222 \
  jumpserver/jms_all:latest
```

启动完成后访问 `http://<服务器 IP>/`：

- 用户名：`admin`
- 密码：`ChangeMe`

> [!IMPORTANT]
> `SECRET_KEY` 用于加密数据库中的敏感字段。请替换为长度不少于 50 位的随机字母数字串（不要包含特殊字符），并妥善保存。首次部署后不可更改，否则数据库中所有加密字段都将无法解密。`BOOTSTRAP_TOKEN` 建议同时替换为不少于 24 位的随机字符串，并在重启、升级时保持不变。

查看启动日志：

```sh
docker logs -f jms_all
```

## 使用 Docker Compose

仓库提供了 `docker-compose.yml` 与 `.env.example`，适合需要固定配置的长期运行场景：

```sh
cd allinone
cp .env.example .env
# 编辑 .env，至少修改 SECRET_KEY 和 BOOTSTRAP_TOKEN
docker compose up -d
```

`docker compose` 会自动创建 `jsdata` 与 `pgdata` 两个命名卷，并复用下方的端口配置。

## 外置数据库与 Redis

all-in-one 也支持外置数据库与缓存，适用于数据需要独立运维或复用的场景。

要求：

- 数据库：MariaDB `>= 10.6` 或 PostgreSQL `>= 13`；
- Redis：`>= 6.2`。

创建 MySQL 用户与数据库（密码请自行替换）：

```mysql
create database jumpserver default charset 'utf8';
create user 'jumpserver'@'%' identified by '<your-db-password>';
grant all on jumpserver.* to 'jumpserver'@'%';
flush privileges;
```

启动时传入外置服务地址：

```sh
docker run -d --name jms_all \
  -p 80:80 \
  -p 2222:2222 \
  -e SECRET_KEY=[API_KEY] \
  -e BOOTSTRAP_TOKEN=xxxxxx \
  -e LOG_LEVEL=INFO \
  -e DB_ENGINE=mysql \
  -e DB_HOST=192.168.x.x \
  -e DB_PORT=3306 \
  -e DB_USER=jumpserver \
  -e DB_PASSWORD=<your-db-password> \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=<your-redis-password> \
  --privileged=true \
  -v jsdata:/opt/data \
  jumpserver/jms_all:latest
```

使用外置数据库时可省略 `pgdata` 卷；外置 Redis 时容器不会启动内置 Redis。`DB_HOST` / `REDIS_HOST` 不是 `127.0.0.1` 时，容器会跳过对应的内置服务。

## 环境变量

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `SECRET_KEY` | `PleaseChangeMe`（必须修改） | 加密密钥，不少于 50 位随机字母数字串，部署后不可更改 |
| `BOOTSTRAP_TOKEN` | `PleaseChangeMe` | 组件注册密钥，建议不少于 24 位，重启、升级时需保持一致，否则组件注册失败 |
| `CHAT_AI_DELEGATION_SECRET` | 由 `BOOTSTRAP_TOKEN` 派生 | 可选，覆盖 AI 委托签名密钥，至少 32 字符 |
| `LOG_LEVEL` | `INFO` | 日志等级，可选 `DEBUG`、`INFO`、`WARNING`、`ERROR` |
| `CORE_HOST` | `http://localhost:8080` | Core 内部访问地址 |
| `DB_ENGINE` | `postgresql` | 数据库类型，可选 `postgresql`、`mysql` |
| `DB_HOST` | `127.0.0.1` | 数据库地址 |
| `DB_PORT` | `5432` | 数据库端口，MySQL 通常为 `3306` |
| `DB_USER` | `postgres` | 数据库用户 |
| `DB_PASSWORD` | `PleaseChangeMe` | 数据库密码 |
| `DB_NAME` | `jumpserver` | 数据库名称 |
| `REDIS_HOST` | `127.0.0.1` | Redis 地址 |
| `REDIS_PORT` | `6379` | Redis 端口 |
| `REDIS_PASSWORD` | `PleaseChangeMe` | Redis 密码 |

> [!TIP]
> 以上信息请在首次部署时记录保存，升级和迁移时需要重新传入相同的值。

## 端口

| 端口 | 说明 |
| --- | --- |
| `80/tcp` | Web 访问入口 |
| `2222/tcp` | Koko SSH 接入端口 |

## 数据持久化

| 挂载点 | 卷示例 | 内容 |
| --- | --- | --- |
| `/opt/data` | `jsdata` | 统一数据目录，包含 Core、Koko、Chen、Kael 的数据，以及 Nginx 日志、Redis 数据 |
| `/var/lib/postgresql` | `pgdata` | 内置 PostgreSQL 数据目录 |
| `/opt/download` | — | 应用发布机所需文件（可选） |

`/opt/data` 下的子目录由入口脚本自动创建并软链接，无需手动准备。若需备份，内置数据库场景请同时备份 `jsdata` 与 `pgdata` 卷；使用外置数据库时还需备份对应数据库。

## 图形会话与 AI 服务

- 图形会话由 Koko 提供，通过 `/koko/lion/` 访问。guacd 随 Koko 镜像打包，由 Supervisor 启动，图形会话录像和文件保存在 Koko 数据目录中。
- 升级前请处理旧 `/opt/data/lion` 中未上传的录像及需要保留的文件，该目录不会自动迁移到 Koko。
- Kael 提供 AI 服务，通过 `/kael/` 访问。镜像包含其所需的 Node.js 与 Codex CLI，数据持久化到 `/opt/data/kael`。
- Kael 复用 `BOOTSTRAP_TOKEN` 注册组件。委托调用 Core API 所需的签名密钥默认由 `BOOTSTRAP_TOKEN` 通过 HMAC-SHA256 确定性派生，并同时传给 Core 和 Kael，无需额外配置或保存密钥文件。重启、升级时保持 `BOOTSTRAP_TOKEN` 不变即可保持该签名密钥不变。若已单独设置 `CHAT_AI_DELEGATION_SECRET`（至少 32 字符），则优先沿用该值，启动时仍需传入。模型服务在 Core 中配置。

## 升级

```sh
# 1. 记录当前配置
docker exec -it jms_all env

# 2. 备份数据
#    内置数据库：备份 jsdata 与 pgdata 卷
#    外置数据库：使用 mysqldump / pg_dump 备份，例如
#    以下 DB_* 变量请替换为上一步查到的值
mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME > jumpserver-backup.sql

# 3. 停止并删除旧容器（数据卷保留）
docker stop jms_all
docker rm jms_all

# 4. 拉取新版本并按原参数重新启动
docker pull jumpserver/jms_all:v5.0.0
```

重新启动时会自动执行 `upgrade_db` 更新数据库结构。请务必使用与旧容器完全相同的 `SECRET_KEY` 和 `BOOTSTRAP_TOKEN`。

## 排错

| 现象 | 排查方式 |
| --- | --- |
| 容器启动后立即退出 | `docker logs jms_all` 查看入口脚本输出，确认数据库/Redis 连接与初始化是否正常 |
| Web 打不开 | 确认 `80` 端口未被占用，并检查 `curl -fsS http://127.0.0.1/api/health/` |
| 数据库等待超时 | 外置数据库时检查 `DB_HOST` / `DB_PORT` 连通性与账号权限 |
| Redis 等待超时 | 外置 Redis 时检查 `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` |
| 升级后加密数据无法解密 | `SECRET_KEY` 与首次部署不一致，需恢复原值 |

进入容器调试：

```sh
docker exec -it jms_all bash
```

如需以 Shell 启动一次性容器（不启动服务），可在启动命令后追加 `bash` 或 `sh`，入口脚本会直接打开 Shell：

```sh
docker run --rm -it -v jsdata:/opt/data jumpserver/jms_all:latest bash
```

## 构建镜像

```sh
cd allinone

# 默认构建 v5.0.0
./build.sh

# 指定版本，需确保 jumpserver/*:<version>-ce 标签存在
./build.sh <version>
```

构建基于 `jumpserver/core`、`koko`、`chen`、`kael`、`web` 的 `${version}-ce` 镜像，最终产物为 `jumpserver/jms_all:<version>`。运行 `demo_run.sh` 可在 `8085` 端口启动本地构建的镜像（默认 `v5.0.0`，可传入版本号）。

## 初始账号

- 用户名：`admin`
- 密码：`ChangeMe`
