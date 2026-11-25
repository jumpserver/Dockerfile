# Docker Swarm Cluster Deployment

[English](README.md) · [简体中文](README.zh-hans.md) · [繁體中文](README.zh-hant.md)

Deploy the JumpServer components with Docker Swarm. This suits horizontal scaling or environments that already run container infrastructure.

The stack currently deploys Core, Celery, Chen, Koko and Web. Kael is not part of the Swarm stack.

## Prerequisites

- An initialized Docker Swarm cluster.
- The same shared storage (NFS, GlusterFS, Ceph, etc.) mounted on every Worker node that may run JumpServer services.
- An external database and Redis:
  - Database: MariaDB `>= 10.6` or PostgreSQL `>= 13`;
  - Redis: `>= 6.2`.
- Graphical sessions and guacd are provided by the Koko container and use Koko's data directory.

> [!NOTE]
> When upgrading from an older version, remove `GUA_HOST=guacd` from `.env` and use Koko's local guacd. Keep the setting only if an external guacd is really required.

## 1. Prepare shared storage

Mount the shared storage on **all** Worker nodes (the example uses the default `/opt/jumpserver` from `config_example.conf`) and create the required directories manually:

```sh
# Docker Swarm does not create mount directories automatically
mkdir -p /opt/jumpserver/core/data
mkdir -p /opt/jumpserver/chen/data
mkdir -p /opt/jumpserver/koko/data
mkdir -p /opt/jumpserver/web/data/logs
mkdir -p /opt/jumpserver/web/download
```

## 2. Prepare the configuration

```sh
git clone --depth=1 https://github.com/jumpserver/Dockerfile.git
cd Dockerfile/swarm
cp config_example.conf .env
vi .env
```

Settings to review:

| Setting | Description |
| --- | --- |
| `VERSION` | Image version, e.g. `v5.0.0`, which maps to `jumpserver/*:v5.0.0-ce` |
| `VOLUME_DIR` | Shared storage directory; must match the directories created in step 1 |
| `NETWORK_DRIVER` | Use `overlay` in Swarm mode |
| `DB_HOST` / `DB_PORT` / `DB_USER` / `DB_PASSWORD` / `DB_NAME` | External database connection |
| `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` | External Redis connection |
| `SECRET_KEY` | Encryption key; change it on first install and never change it afterwards |
| `BOOTSTRAP_TOKEN` | Component registration token, used only when components register (koko, chen, etc.) |
| `CORE_HOST` | Inter-component address, defaults to `http://core:8080` |
| `HTTP_PORT` / `SSH_PORT` | Published web and SSH ports |
| `DOMAINS` | Public domains, comma-separated |

> [!IMPORTANT]
> `SECRET_KEY` protects signed data and must not change after deployment, otherwise encrypted data cannot be decrypted. Keep `BOOTSTRAP_TOKEN` unchanged across restarts and scaling, otherwise components cannot register.

## 3. Generate the stack files

`docker-compose*.yml` files are Compose format and must be converted into Swarm stack files:

```sh
docker compose -f docker-compose-network.yml -f docker-compose-init-db.yml config \
  | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack-init-db.yml

docker compose -f docker-compose-network.yml -f docker-compose.yml config \
  | sed '/published:/ s/"//g' | sed "/name:/d" > docker-stack.yml
```

## 4. Initialize the database

```sh
docker stack deploy -c docker-stack-init-db.yml jumpserver
docker service ls
docker service ps jumpserver_init_db
```

Use `docker service ps` to find the node running the job, then check the initialization log there to confirm the schema upgrade finished.

## 5. Deploy the application

```sh
docker stack deploy --prune -c docker-stack.yml jumpserver
docker service ls
```

`--prune` removes component services that are no longer in the configuration. When deployment finishes, open `http://<node-ip>:<HTTP_PORT>/`.

## Operations

```sh
# Scale koko to 2 replicas
docker service update --replicas=2 jumpserver_koko

# Follow service logs
docker service logs -f jumpserver_core

# Upgrade: edit VERSION in .env, regenerate the stack file, then deploy
docker stack deploy --prune -c docker-stack.yml jumpserver

# Tear down
docker stack rm jumpserver
```

> [!TIP]
> The bundled `docker-compose-mariadb.yml` and `docker-compose-redis.yml` are for single-host Compose setups that need a quick database and cache. In Swarm mode, use your own database and Redis.

## Initial account

- Username: `admin`
- Password: `ChangeMe`
