<div align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>

  <h3>JumpServer Docker 部署</h3>

  <p>JumpServer all-in-one 映像與 Docker Swarm 叢集編排檔案</p>

  <p>
    <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
    <a href="https://hub.docker.com/r/jumpserver/jms_all"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Docker Pulls"></a>
    <a href="https://github.com/jumpserver/Dockerfile/commits"><img src="https://img.shields.io/github/last-commit/jumpserver/Dockerfile" alt="Last commit"></a>
    <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="GitHub Stars"></a>
  </p>

  <p><a href="README.md">English</a> · <a href="README.zh-hans.md">簡體中文</a> · 繁體中文</p>
</div>

---

## 簡介

本倉庫維護 JumpServer 的容器化部署檔案，提供兩種開箱即用的部署方式：

| 方式 | 說明 | 適用場景 |
| --- | --- | --- |
| [all-in-one](allinone) | 單個容器內執行 Core、Web 和 KoKo（內含 Chen、guacd 和 Kael），並內建 PostgreSQL 與 Redis | 體驗、測試、小規模部署 |
| [Docker Swarm](swarm) | 使用官方拆分映像編排叢集服務，資料庫與 Redis 需自行準備 | 叢集部署、需要橫向擴容 |

> [!TIP]
> 生產環境建議使用 [JumpServer 安裝包](https://docs.jumpserver.org/zh/v3/quick_start/) 完成標準部署；all-in-one 與 Swarm 方式更適合測試和已有容器基礎設施的場景。

## 快速開始

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

啟動完成後訪問 `http://<伺服器 IP>/`，預設帳號如下：

- 使用者名稱：`admin`
- 密碼：`ChangeMe`

> [!IMPORTANT]
> `SECRET_KEY` 用於加密資料庫中的敏感欄位，請替換為長度不少於 50 位的隨機字母數字串並妥善儲存。首次部署後不可更改，否則資料庫中的加密欄位將無法解密。`BOOTSTRAP_TOKEN` 建議同時替換為不少於 24 位的隨機字串。

更多參數、外接資料庫、升級與排錯，請閱讀 [all-in-one 部署文件](allinone/README.zh-hant.md)。也可以直接使用倉庫內的 [docker-compose.yml](allinone/docker-compose.yml) 啟動。

## 架構與元件

all-in-one 映像內整合以下服務：

| 元件 | 說明 | 埠 / 入口 |
| --- | --- | --- |
| Core | JumpServer 核心 API 與排程服務 | 容器內 `8080` |
| Web | Nginx 前端與反向代理 | `80` |
| Koko | 字元協定連接器，提供 SSH/SFTP 等會話；映像內建 guacd 提供圖形會話 | `2222`，Web 入口 `/koko/` |
| Chen | KoKo 內建的資料庫工作台 | API 路徑 `/koko/chen/api/v1/` |
| Kael | 隨 KoKo 映像提供的 AI 服務 | `/kael/` |
| PostgreSQL | 內建資料庫，可通過環境變數切換為外接資料庫 | `5432` |
| Redis | 內建快取，可替換為外接 Redis | `6379` |

## 埠與資料

| 專案 | 說明 |
| --- | --- |
| `80/tcp` | Web 訪問入口 |
| `2222/tcp` | Koko SSH 接入埠 |
| `jsdata:/opt/data` | 統一資料卷，包含各元件資料、Nginx 日誌與 Redis 資料 |
| `pgdata:/var/lib/postgresql` | 內建 PostgreSQL 資料目錄（使用外接資料庫時無需掛載） |
| `/opt/download` | 應用釋出機所需檔案（可選） |

## 目錄結構

```text
.
├── allinone/            # all-in-one 映像構建檔案與部署文件
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
└── swarm/               # Docker Swarm 叢集編排檔案與部署文件
    ├── config_example.conf
    ├── docker-compose*.yml
    ├── README.md
    ├── README.zh-hans.md
    └── README.zh-hant.md
```

## 相關倉庫

- [jumpserver/jumpserver](https://github.com/jumpserver/jumpserver)：JumpServer 主倉庫
- [jumpserver/koko](https://github.com/jumpserver/koko)：字元協定連接器
- [jumpserver/lina](https://github.com/jumpserver/lina)：Web 管理控制台
- [jumpserver/luna](https://github.com/jumpserver/luna)：Web 終端

## 反饋與貢獻

問題反饋與功能建議請提交 [Issue](https://github.com/jumpserver/jumpserver/issues)；歡迎通過 Pull Request 改進構建指令碼與文件。

## 許可證

Copyright (c) 2014-2026 FIT2CLOUD, All rights reserved.

本項目基於 GNU General Public License version 3（GPLv3）許可，與 [JumpServer 主倉庫](https://github.com/jumpserver/jumpserver)一致。完整許可文本請參閱 [LICENSE](LICENSE)。
