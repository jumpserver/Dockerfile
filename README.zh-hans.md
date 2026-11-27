<div align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>

  <h3>JumpServer Docker 部署</h3>

  <p>JumpServer all-in-one 镜像与 Docker Swarm 集群编排文件</p>

  <p>
    <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
    <a href="https://hub.docker.com/r/jumpserver/jms_all"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Docker Pulls"></a>
    <a href="https://github.com/jumpserver/Dockerfile/commits"><img src="https://img.shields.io/github/last-commit/jumpserver/Dockerfile" alt="Last commit"></a>
    <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="GitHub Stars"></a>
  </p>

  <p><a href="README.md">English</a> · 简体中文 · <a href="README.zh-hant.md">繁體中文</a></p>
</div>

---

## 简介

本仓库维护 JumpServer 的容器化部署文件，提供两种开箱即用的部署方式：

| 方式 | 说明 | 适用场景 |
| --- | --- | --- |
| [all-in-one](allinone) | 单个容器内运行 Core、Web 和 KoKo（内含 Chen、guacd 和 Kael），并内置 PostgreSQL 与 Redis | 体验、测试、小规模部署 |
| [Docker Swarm](swarm) | 使用官方拆分镜像编排集群服务，数据库与 Redis 需自行准备 | 集群部署、需要横向扩容 |

> [!TIP]
> 生产环境建议使用 [JumpServer 安装包](https://docs.jumpserver.org/zh/v3/quick_start/) 完成标准部署；all-in-one 与 Swarm 方式更适合测试和已有容器基础设施的场景。

## 快速开始

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

启动完成后访问 `http://<服务器 IP>/`，默认账号如下：

- 用户名：`admin`
- 密码：`ChangeMe`

> [!IMPORTANT]
> `SECRET_KEY` 用于加密数据库中的敏感字段，请替换为长度不少于 50 位的随机字母数字串并妥善保存。首次部署后不可更改，否则数据库中的加密字段将无法解密。`BOOTSTRAP_TOKEN` 建议同时替换为不少于 24 位的随机字符串。

更多参数、外置数据库、升级与排错，请阅读 [all-in-one 部署文档](allinone/README.zh-hans.md)。也可以直接使用仓库内的 [docker-compose.yml](allinone/docker-compose.yml) 启动。

## 架构与组件

all-in-one 镜像内集成以下服务：

| 组件 | 说明 | 端口 / 入口 |
| --- | --- | --- |
| Core | JumpServer 核心 API 与调度服务 | 容器内 `8080` |
| Web | Nginx 前端与反向代理 | `80` |
| Koko | 字符协议连接器，提供 SSH/SFTP 等会话；镜像内置 guacd 提供图形会话 | `2222`，Web 入口 `/koko/` |
| Chen | KoKo 内置的数据库工作台 | API 路径 `/koko/chen/api/v1/` |
| Kael | 随 KoKo 镜像交付的 AI 服务 | `/kael/` |
| PostgreSQL | 内置数据库，可通过环境变量切换为外置数据库 | `5432` |
| Redis | 内置缓存，可替换为外置 Redis | `6379` |

## 端口与数据

| 项目 | 说明 |
| --- | --- |
| `80/tcp` | Web 访问入口 |
| `2222/tcp` | Koko SSH 接入端口 |
| `jsdata:/opt/data` | 统一数据卷，包含各组件数据、Nginx 日志与 Redis 数据 |
| `pgdata:/var/lib/postgresql` | 内置 PostgreSQL 数据目录（使用外置数据库时无需挂载） |
| `/opt/download` | 应用发布机所需文件（可选） |

## 目录结构

```text
.
├── allinone/            # all-in-one 镜像构建文件与部署文档
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── s6/
│   ├── web-run
│   ├── docker-compose.yml
│   ├── .env.example
│   ├── build.sh
│   ├── README.md
│   ├── README.zh-hans.md
│   └── README.zh-hant.md
└── swarm/               # Docker Swarm 集群编排文件与部署文档
    ├── config_example.conf
    ├── docker-compose*.yml
    ├── README.md
    ├── README.zh-hans.md
    └── README.zh-hant.md
```

## 相关仓库

- [jumpserver/jumpserver](https://github.com/jumpserver/jumpserver)：JumpServer 主仓库
- [jumpserver/koko](https://github.com/jumpserver/koko)：字符协议连接器
- [jumpserver/lina](https://github.com/jumpserver/lina)：Web 管理控制台
- [jumpserver/luna](https://github.com/jumpserver/luna)：Web 终端

## 反馈与贡献

问题反馈与功能建议请提交 [Issue](https://github.com/jumpserver/jumpserver/issues)；欢迎通过 Pull Request 改进构建脚本与文档。

## 许可证

Copyright (c) 2014-2026 FIT2CLOUD, All rights reserved.

本项目基于 GNU General Public License version 3（GPLv3）许可，与 [JumpServer 主仓库](https://github.com/jumpserver/jumpserver)一致。完整许可文本请参阅 [LICENSE](LICENSE)。
