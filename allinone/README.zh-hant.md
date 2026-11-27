# JumpServer all-in-one

[English](README.md) · [簡體中文](README.zh-hans.md) · 繁體中文

JumpServer all-in-one 部署方式的映像構建與執行檔案。單個容器內執行 Core、Web 和 KoKo（內含 Chen、guacd 和 Kael），並內建 PostgreSQL 與 Redis，適合快速體驗、測試和小規模部署。

> [!NOTE]
> all-in-one 不支援 Client 相關功能，僅支援純 B/S 架構的 Web 端使用。生產環境請使用 [JumpServer 安裝包](https://docs.jumpserver.org/zh/v3/quick_start/) 進行標準部署。

## 映像內容

| 元件 | 說明 | 埠 / 入口 |
| --- | --- | --- |
| Core | JumpServer 核心 API 與排程服務 | 容器內 `8080` |
| Web | Nginx 前端與反向代理 | `80` |
| Koko | 字元協定連接器；映像內建 guacd，提供圖形會話 | `2222`，Web 入口 `/koko/lion/` |
| Chen | KoKo 內建的資料庫工作台 | API 路徑 `/koko/chen/api/v1/` |
| Kael | 隨 KoKo 映像提供的 AI 服務 | `/kael/` |
| PostgreSQL | 內建資料庫，支援切換為外接 MySQL/PostgreSQL | `5432` |
| Redis | 內建快取，支援切換為外接 Redis | `6379` |

s6-overlay 管理容器程序。使用內建儲存時，先啟動 PostgreSQL 和 Redis；資料庫遷移成功後啟動 Core。Core 通過健康檢查後，KoKo 初始化元件，Web 開始提供服務。

## 前置條件

- 已安裝 Docker，映像僅提供 `linux/amd64` 版本；
- 宿主機需可訪問 Docker Hub（或已提前拉取映像）；
- 首次啟動會初始化資料庫並執行 `upgrade_db`，耗時取決於機器效能。

## 快速開始

使用內建 PostgreSQL 與 Redis 啟動：

```sh
docker volume create jsdata
docker volume create pgdata

docker run -d --name jms_all --stop-timeout 90 \
  -e SECRET_KEY=[API_KEY] \
  -e BOOTSTRAP_TOKEN=PleaseChangeMe \
  -v jsdata:/opt/data \
  -v pgdata:/var/lib/postgresql \
  -p 80:80 \
  -p 2222:2222 \
  jumpserver/jms_all:latest
```

啟動完成後訪問 `http://<伺服器 IP>/`：

- 使用者名稱：`admin`
- 密碼：`ChangeMe`

> [!IMPORTANT]
> `SECRET_KEY` 用於加密資料庫中的敏感欄位。請替換為長度不少於 50 位的隨機字母數字串（不要包含特殊字元），並妥善儲存。首次部署後不可更改，否則資料庫中所有加密欄位都將無法解密。`BOOTSTRAP_TOKEN` 建議同時替換為不少於 24 位的隨機字串，並在重啟、升級時保持不變。

檢視啟動日誌：

```sh
docker logs -f jms_all
# 檢視服務狀態
docker exec jms_all /command/s6-rc -a list
docker exec jms_all /command/s6-svstat /run/service/koko
```

## 使用 Docker Compose

倉庫提供了 `docker-compose.yml` 與 `.env.example`，適合需要固定設定的長期執行場景：

```sh
cd allinone
cp .env.example .env
# 編輯 .env，至少修改 SECRET_KEY 和 BOOTSTRAP_TOKEN
docker compose up -d
```

`docker compose` 會自動建立 `jsdata` 與 `pgdata` 兩個命名卷，並複用下方的埠設定。

## 外接資料庫與 Redis

all-in-one 也支援外接資料庫與快取，適用於資料需要獨立運維或複用的場景。

要求：

- 資料庫：MariaDB `>= 10.6` 或 PostgreSQL `>= 13`；
- Redis：`>= 6.2`。

建立 MySQL 使用者與資料庫（密碼請自行替換）：

```mysql
create database jumpserver default charset 'utf8';
create user 'jumpserver'@'%' identified by '<your-db-password>';
grant all on jumpserver.* to 'jumpserver'@'%';
flush privileges;
```

啟動時傳入外接服務地址：

```sh
docker run -d --name jms_all --stop-timeout 90 \
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

使用外接資料庫時可省略 `pgdata` 卷；外接 Redis 時容器不會啟動內建 Redis。`DB_HOST` / `REDIS_HOST` 不是 `127.0.0.1` 時，容器會跳過對應的內建服務。

## 環境變數

| 變數 | 預設值 | 說明 |
| --- | --- | --- |
| `SECRET_KEY` | `PleaseChangeMe`（必須修改） | 加密金鑰，不少於 50 位隨機字母數字串，部署後不可更改 |
| `BOOTSTRAP_TOKEN` | `PleaseChangeMe` | 元件註冊金鑰，建議不少於 24 位，重啟、升級時需保持一致，否則元件註冊失敗 |
| `KAEL_ENABLED` | `1` | 設為 `0` 關閉 AI 程序和 Web 路由 |
| `CHAT_AI_DELEGATION_SECRET` | 由 `BOOTSTRAP_TOKEN` 派生 | 可選，覆蓋 AI 委託簽名金鑰，至少 32 字元 |
| `LOG_LEVEL` | `INFO` | 日誌等級，可選 `DEBUG`、`INFO`、`WARNING`、`ERROR` |
| `CORE_HOST` | `http://localhost:8080` | Core 內部訪問地址 |
| `DB_ENGINE` | `postgresql` | 資料庫型別，可選 `postgresql`、`mysql` |
| `DB_HOST` | `127.0.0.1` | 資料庫地址 |
| `DB_PORT` | `5432` | 資料庫埠，MySQL 通常為 `3306` |
| `DB_USER` | `postgres` | 資料庫使用者 |
| `DB_PASSWORD` | `PleaseChangeMe` | 資料庫密碼 |
| `DB_NAME` | `jumpserver` | 資料庫名稱 |
| `REDIS_HOST` | `127.0.0.1` | Redis 地址 |
| `REDIS_PORT` | `6379` | Redis 埠 |
| `REDIS_PASSWORD` | `PleaseChangeMe` | Redis 密碼 |

> [!TIP]
> 以上資訊請在首次部署時記錄儲存，升級和遷移時需要重新傳入相同的值。

## 埠

| 埠 | 說明 |
| --- | --- |
| `80/tcp` | Web 訪問入口 |
| `2222/tcp` | Koko SSH 接入埠 |

## 資料持久化

| 掛載點 | 卷示例 | 內容 |
| --- | --- | --- |
| `/opt/data` | `jsdata` | 統一資料目錄，包含 Core、Koko、Chen、Kael 的資料，以及 Nginx 日誌、Redis 資料 |
| `/var/lib/postgresql` | `pgdata` | 內建 PostgreSQL 資料目錄 |
| `/opt/download` | — | 應用釋出機所需檔案（可選） |

`/opt/data` 下的子目錄由入口指令碼自動建立並軟連結，無需手動準備。若需備份，內建資料庫場景請同時備份 `jsdata` 與 `pgdata` 卷；使用外接資料庫時還需備份對應資料庫。

## 圖形會話與 AI 服務

- 圖形會話由 Koko 提供，通過 `/koko/lion/` 訪問。guacd 隨 Koko 映像打包，由 s6 啟動，圖形會話錄影和檔案儲存在 Koko 資料目錄中。
- 升級前請處理舊 `/opt/data/lion` 中未上傳的錄影及需要保留的檔案，該目錄不會自動遷移到 Koko。
- Kael 使用 KoKo 內建的獨立 Codex CLI，繼續從 `/opt/data/kael` 讀取元件身分和資料。
- Kael 使用 `BOOTSTRAP_TOKEN` 註冊，再用元件金鑰存取 Core。升級時沿用已為 Core 設定的 `CHAT_AI_DELEGATION_SECRET`。

## 升級

從 v5.2.x 或更早版本升級前，先結束 Chen 會話，等候稽核和錄影上傳完成。保留舊 `/opt/data/chen` 以便復原。KoKo 將新的工作台狀態寫入 `/opt/data/koko/chen`。

```sh
# 1. 記錄當前設定
docker exec -it jms_all env

# 2. 備份資料
#    內建資料庫：備份 jsdata 與 pgdata 卷
#    外接資料庫：使用 mysqldump / pg_dump 備份，例如
#    以下 DB_* 變數請替換為上一步查到的值
mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME > jumpserver-backup.sql

# 3. 停止並刪除舊容器（資料卷保留）
docker stop -t 90 jms_all
docker rm jms_all

# 4. 拉取新版本並按原參數重新啟動
docker pull jumpserver/jms_all:v5.3.0
```

重新啟動時會自動執行 `upgrade_db` 更新資料庫結構。請務必使用與舊容器完全相同的 `SECRET_KEY` 和 `BOOTSTRAP_TOKEN`。

## 排錯

| 現象 | 排查方式 |
| --- | --- |
| 容器啟動後立即退出 | `docker logs jms_all` 檢視入口指令碼輸出，確認資料庫/Redis 連線與初始化是否正常 |
| Web 打不開 | 確認 `80` 埠未被佔用，並檢查 `curl -fsS http://127.0.0.1/api/health/` |
| 資料庫等待超時 | 外接資料庫時檢查 `DB_HOST` / `DB_PORT` 連通性與帳號許可權 |
| Redis 等待超時 | 外接 Redis 時檢查 `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` |
| 升級後加密資料無法解密 | `SECRET_KEY` 與首次部署不一致，需恢復原值 |

進入容器除錯：

```sh
docker exec -it jms_all bash
```

如需以 Shell 啟動一次性容器（不啟動服務），可在啟動命令後追加 `bash` 或 `sh`，入口指令碼會直接開啟 Shell：

```sh
docker run --rm -it -v jsdata:/opt/data jumpserver/jms_all:latest bash
```

## 構建映像

```sh
cd allinone

# 預設構建 v5.3.0
./build.sh

# 指定版本，需確保 jumpserver/*:<version>-ce 標籤存在
./build.sh <version>

# 檢查構建映像的啟動、停機和資料卷複用
./tests/smoke.sh jumpserver/jms_all:v5.3.0
```

構建基於 `jumpserver/core`、`koko`、`web` 的 `${version}-ce` 映像，最終產物為 `jumpserver/jms_all:<version>`。執行 `demo_run.sh` 可在 `8085` 埠啟動本地構建的映像（預設 `v5.3.0`，可傳入版本號）。 構建 v5.2.x 或更早版本時，先切換到本倉庫對應的發行標籤。

## 初始帳號

- 使用者名稱：`admin`
- 密碼：`ChangeMe`
