# Docker Swarm 叢集部署

[English](README.md) · [簡體中文](README.zh-hans.md) · 繁體中文

使用 Docker Swarm 編排 JumpServer 各元件，適合需要橫向擴容、或已有容器基礎設施的環境。

當前編排包含 Core、Celery、Chen、Koko、Web，不包含 Kael。

## 前置條件

- 已初始化 Docker Swarm 叢集；
- 所有可能執行 JumpServer 服務的 Worker 節點掛載了同一份共享儲存（NFS、GlusterFS、Ceph 等）；
- 自備資料庫與 Redis：
  - 資料庫：MariaDB `>= 10.6` 或 PostgreSQL `>= 13`；
  - Redis：`>= 6.2`；
- 圖形會話與 guacd 均由 Koko 容器提供，使用 Koko 資料目錄。

> [!NOTE]
> 從舊版本升級時，請移除 `.env` 中的 `GUA_HOST=guacd`，改用 Koko 預設的本地 guacd；如確實需要外接 guacd，可以繼續保留該設定。

## 1. 準備共享儲存

在**所有** Worker 節點掛載共享儲存（示例使用 `config_example.conf` 中的預設值 `/opt/jumpserver`），並手動建立所需目錄：

```sh
# 注意: Docker Swarm 模式不會自動建立掛載目錄
mkdir -p /opt/jumpserver/core/data
mkdir -p /opt/jumpserver/chen/data
mkdir -p /opt/jumpserver/koko/data
mkdir -p /opt/jumpserver/web/data/logs
mkdir -p /opt/jumpserver/web/download
```

## 2. 準備設定檔

```sh
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile/swarm
cp config_example.conf .env
vi .env
```

需要重點確認的設定項：

| 設定 | 說明 |
| --- | --- |
| `VERSION` | 映像版本，例如 `v5.0.0`，對應 `jumpserver/*:v5.0.0-ce` |
| `VOLUME_DIR` | 共享儲存目錄，需與第 1 步建立的目錄一致 |
| `NETWORK_DRIVER` | Swarm 模式使用 `overlay` |
| `DB_HOST` / `DB_PORT` / `DB_USER` / `DB_PASSWORD` / `DB_NAME` | 自備資料庫連線資訊 |
| `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` | 自備 Redis 連線資訊 |
| `SECRET_KEY` | 加密金鑰，首次安裝必須修改並牢記，後續升級和遷移不可更改 |
| `BOOTSTRAP_TOKEN` | 元件註冊金鑰，僅元件註冊時使用（koko、chen 等） |
| `CORE_HOST` | 元件通訊地址，預設 `http://core:8080` |
| `HTTP_PORT` / `SSH_PORT` | Web 與 SSH 對外埠 |
| `DOMAINS` | 對外訪問域名，多個域名以逗號分隔 |

> [!IMPORTANT]
> `SECRET_KEY` 是保護簽名資料的金鑰，部署後不可更改，否則加密資料將無法解密；`BOOTSTRAP_TOKEN` 在重啟、擴容時需保持一致，否則元件無法註冊。

## 3. 生成 stack 檔案

`docker-compose*.yml` 為 Compose 格式，需要轉換成 Swarm 可用的 stack 檔案：

```sh
docker compose -f docker-compose-network.yml -f docker-compose-init-db.yml config \
  | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack-init-db.yml

docker compose -f docker-compose-network.yml -f docker-compose.yml config \
  | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack.yml
```

## 4. 初始化資料庫

```sh
docker stack deploy -c docker-stack-init-db.yml jumpserver
docker service ls
docker service ps jumpserver_init_db
```

根據 `docker service ps` 輸出的節點，到對應 Worker 節點檢視初始化日誌，確認資料庫結構升級完成。

## 5. 部署應用

```sh
docker stack deploy --prune -c docker-stack.yml jumpserver
docker service ls
```

`--prune` 會清理設定中已移除的元件服務。部署完成後訪問 `http://<節點 IP>:<HTTP_PORT>/`。

## 運維

```sh
# 擴容 koko 到 2 個副本
docker service update --replicas=2 jumpserver_koko

# 檢視服務日誌
docker service logs -f jumpserver_core

# 更新映像版本：修改 .env 中的 VERSION 後重新生成並部署
docker stack deploy --prune -c docker-stack.yml jumpserver

# 下線
docker stack rm jumpserver
```

> [!TIP]
> 內建的 `docker-compose-mariadb.yml` 與 `docker-compose-redis.yml` 可用於單機 Compose 場景快速準備資料庫和快取，Swarm 模式請使用自備的資料庫與 Redis。

## 初始帳號

- 使用者名稱：`admin`
- 密碼：`ChangeMe`
