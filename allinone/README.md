# JumpServer all-in-one

English · [简体中文](README.zh-hans.md) · [繁體中文](README.zh-hant.md)

Build and runtime files for the JumpServer all-in-one deployment. Core, Koko, Chen, Kael and Web run in a single container, with PostgreSQL and Redis bundled. It is intended for evaluation, testing and small deployments.

> [!NOTE]
> all-in-one does not support Client-related features and only works with the pure B/S web interface. For production, use the [JumpServer installer](https://docs.jumpserver.org/zh/v3/quick_start/).

## What's inside

| Component | Description | Port / Path |
| --- | --- | --- |
| Core | JumpServer core API and scheduler | `8080` inside the container |
| Web | Nginx frontend and reverse proxy | `80` |
| Koko | Character protocol connector; guacd is bundled for graphical sessions | `2222`, web path `/koko/lion/` |
| Chen | Web database connector | web path `/chen/` |
| Kael | AI service, registered with `BOOTSTRAP_TOKEN` | web path `/kael/` |
| PostgreSQL | Bundled database, swappable for an external MySQL/PostgreSQL | `5432` |
| Redis | Bundled cache, swappable for an external Redis | `6379` |

PostgreSQL and Redis are started by the entrypoint; the remaining services run under Supervisor and are restarted automatically if they exit.

## Prerequisites

- Docker is installed. The image is published for `linux/amd64` only.
- The host can reach Docker Hub, or the image has been pulled in advance.
- The first start initializes the database and runs `upgrade_db`, which can take a while.

## Quick start

Start with the bundled PostgreSQL and Redis:

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

Open `http://<server-ip>/` and sign in with:

- Username: `admin`
- Password: `ChangeMe`

> [!IMPORTANT]
> `SECRET_KEY` encrypts sensitive database fields. Replace it with a random alphanumeric string of at least 50 characters (no special characters) and keep it safe. It must not change after the first deployment, otherwise every encrypted field becomes undecryptable. Replace `BOOTSTRAP_TOKEN` with a random string of at least 24 characters and keep it unchanged across restarts and upgrades.

Follow the startup log:

```sh
docker logs -f jms_all
```

## Docker Compose

The repository ships a `docker-compose.yml` and `.env.example` for long-running deployments with fixed configuration:

```sh
cd allinone
cp .env.example .env
# Edit .env and at least change SECRET_KEY and BOOTSTRAP_TOKEN
docker compose up -d
```

Compose creates the `jsdata` and `pgdata` named volumes automatically and uses the port settings described below.

## External database and Redis

all-in-one can also use an external database and cache. Requirements:

- Database: MariaDB `>= 10.6` or PostgreSQL `>= 13`
- Redis: `>= 6.2`

Create the MySQL database and user (replace the password):

```mysql
create database jumpserver default charset 'utf8';
create user 'jumpserver'@'%' identified by '<your-db-password>';
grant all on jumpserver.* to 'jumpserver'@'%';
flush privileges;
```

Pass the external endpoints at startup:

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

The `pgdata` volume is unnecessary with an external database. When `DB_HOST` or `REDIS_HOST` is not `127.0.0.1`, the container skips the corresponding bundled service.

## Environment variables

| Variable | Default | Description |
| --- | --- | --- |
| `SECRET_KEY` | `PleaseChangeMe` (must change) | Encryption key; at least 50 random alphanumeric characters, immutable after deployment |
| `BOOTSTRAP_TOKEN` | `PleaseChangeMe` | Component registration token; at least 24 characters; keep it unchanged across restarts and upgrades |
| `CHAT_AI_DELEGATION_SECRET` | Derived from `BOOTSTRAP_TOKEN` | Optional override for the AI delegation signing key, at least 32 characters |
| `LOG_LEVEL` | `INFO` | Log level: `DEBUG`, `INFO`, `WARNING` or `ERROR` |
| `CORE_HOST` | `http://localhost:8080` | Internal Core address |
| `DB_ENGINE` | `postgresql` | `postgresql` or `mysql` |
| `DB_HOST` | `127.0.0.1` | Database host |
| `DB_PORT` | `5432` | Database port; usually `3306` for MySQL |
| `DB_USER` | `postgres` | Database user |
| `DB_PASSWORD` | `PleaseChangeMe` | Database password |
| `DB_NAME` | `jumpserver` | Database name |
| `REDIS_HOST` | `127.0.0.1` | Redis host |
| `REDIS_PORT` | `6379` | Redis port |
| `REDIS_PASSWORD` | `PleaseChangeMe` | Redis password |

> [!TIP]
> Record these values when you first deploy. You will need to pass the same values when upgrading or migrating.

## Ports

| Port | Description |
| --- | --- |
| `80/tcp` | Web entrypoint |
| `2222/tcp` | Koko SSH gateway |

## Persistence

| Mount | Volume | Contents |
| --- | --- | --- |
| `/opt/data` | `jsdata` | Unified data directory: Core, Koko, Chen and Kael data, Nginx logs and Redis data |
| `/var/lib/postgresql` | `pgdata` | Bundled PostgreSQL data directory |
| `/opt/download` | — | Files for application publishing hosts (optional) |

Directories under `/opt/data` are created and symlinked by the entrypoint. With the bundled database, back up both the `jsdata` and `pgdata` volumes; with an external database, back up that database as well.

## Graphical sessions and AI service

- Graphical sessions are served by Koko at `/koko/lion/`. guacd is packaged in the Koko image and started by Supervisor; recordings and files are kept in Koko's data directory.
- Before upgrading, process any pending recordings or files in the legacy `/opt/data/lion` directory. It is not migrated to Koko automatically.
- Kael provides the AI service at `/kael/`. The image includes its Node.js and Codex CLI dependencies, and data persists in `/opt/data/kael`.
- Kael reuses `BOOTSTRAP_TOKEN` for registration. The signing key for delegated Core API requests is derived deterministically from `BOOTSTRAP_TOKEN` with HMAC-SHA256 and passed to both Core and Kael, so no extra configuration or key file is needed. Keep `BOOTSTRAP_TOKEN` unchanged across restarts and upgrades to preserve this key. An explicitly configured `CHAT_AI_DELEGATION_SECRET` (at least 32 characters) takes precedence and must still be supplied at startup. Configure the model service in Core.

## Upgrade

```sh
# 1. Record the current configuration
docker exec -it jms_all env

# 2. Back up data
#    Bundled database: back up the jsdata and pgdata volumes
#    External database: use mysqldump / pg_dump, for example
#    Replace the DB_* values below with the ones printed above
mysqldump -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME > jumpserver-backup.sql

# 3. Stop and remove the old container (volumes are kept)
docker stop jms_all
docker rm jms_all

# 4. Pull the new version and start it with the same arguments
docker pull jumpserver/jms_all:v5.0.0
```

The container runs `upgrade_db` automatically on startup. Always reuse the exact same `SECRET_KEY` and `BOOTSTRAP_TOKEN`.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Container exits right away | `docker logs jms_all`; check database/Redis connectivity and initialization |
| Web UI unreachable | Check that port `80` is free and `curl -fsS http://127.0.0.1/api/health/` succeeds |
| Database wait timeout | With an external database, check `DB_HOST` / `DB_PORT` connectivity and credentials |
| Redis wait timeout | With an external Redis, check `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` |
| Encrypted data unreadable after upgrade | `SECRET_KEY` differs from the first deployment; restore the original value |

Open a shell inside the container:

```sh
docker exec -it jms_all bash
```

To start a one-off container with a shell instead of the services, pass `bash` or `sh` as the command; the entrypoint detects it and opens a shell:

```sh
docker run --rm -it -v jsdata:/opt/data jumpserver/jms_all:latest bash
```

## Build the image

```sh
cd allinone

# Build v5.0.0 by default
./build.sh

# Build another version; jumpserver/*:<version>-ce must exist
./build.sh <version>
```

The build uses the `${version}-ce` tags of `jumpserver/core`, `koko`, `chen`, `kael` and `web`, and produces `jumpserver/jms_all:<version>`. Run `demo_run.sh` to start the locally built image on port `8085` (defaults to `v5.0.0`; pass a version to override).

## Initial account

- Username: `admin`
- Password: `ChangeMe`
