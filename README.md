<div align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>

  <h3>JumpServer Docker Deployment</h3>

  <p>All-in-one image and Docker Swarm orchestration for JumpServer</p>

  <p>
    <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
    <a href="https://hub.docker.com/r/jumpserver/jms_all"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Docker Pulls"></a>
    <a href="https://github.com/jumpserver/Dockerfile/commits"><img src="https://img.shields.io/github/last-commit/jumpserver/Dockerfile" alt="Last commit"></a>
    <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="GitHub Stars"></a>
  </p>

  <p>English · <a href="README.zh-hans.md">简体中文</a> · <a href="README.zh-hant.md">繁體中文</a></p>
</div>

---

## Introduction

This repository maintains containerized deployment files for JumpServer and offers two out-of-the-box options:

| Option | Description | Typical use |
| --- | --- | --- |
| [all-in-one](allinone) | Runs Core, Web and KoKo (including Chen, guacd and Kael) in a single container, with PostgreSQL and Redis bundled | Evaluation, testing, small deployments |
| [Docker Swarm](swarm) | Orchestrates the official component images as a cluster; database and Redis must be provided | Clusters and horizontal scaling |

> [!TIP]
> For production, we recommend the [JumpServer installer](https://docs.jumpserver.org/zh/v3/quick_start/). all-in-one and Swarm are intended for testing or environments that already run container infrastructure.

## Quick Start

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

Once the container is running, open `http://<server-ip>/` and sign in with:

- Username: `admin`
- Password: `ChangeMe`

> [!IMPORTANT]
> `SECRET_KEY` encrypts sensitive database fields. Replace it with a random alphanumeric string of at least 50 characters and keep it safe. It must not change after the first deployment, otherwise encrypted fields can no longer be decrypted. Replace `BOOTSTRAP_TOKEN` with a random string of at least 24 characters as well.

See the [all-in-one guide](allinone/README.md) for external databases, upgrades and troubleshooting. You can also start it with the bundled [docker-compose.yml](allinone/docker-compose.yml).

## Architecture

The all-in-one image bundles the following services:

| Component | Description | Port / Path |
| --- | --- | --- |
| Core | JumpServer core API and scheduler | `8080` inside the container |
| Web | Nginx frontend and reverse proxy | `80` |
| Koko | Character protocol connector for SSH/SFTP sessions; guacd is bundled for graphical sessions | `2222`, web path `/koko/` |
| Chen | SQL workbench built into KoKo | API at `/koko/chen/api/v1/` |
| Kael | AI service bundled with KoKo | `/kael/` |
| PostgreSQL | Bundled database, swappable for an external one | `5432` |
| Redis | Bundled cache, swappable for an external one | `6379` |

## Ports and Persistence

| Item | Description |
| --- | --- |
| `80/tcp` | Web entrypoint |
| `2222/tcp` | Koko SSH gateway |
| `jsdata:/opt/data` | Unified data volume for component data, Nginx logs and Redis data |
| `pgdata:/var/lib/postgresql` | Bundled PostgreSQL data directory (not needed with an external database) |
| `/opt/download` | Files for application publishing hosts (optional) |

## Repository Layout

```text
.
├── allinone/            # all-in-one image build files and guide
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
└── swarm/               # Docker Swarm orchestration files and guide
    ├── config_example.conf
    ├── docker-compose*.yml
    ├── README.md
    ├── README.zh-hans.md
    └── README.zh-hant.md
```

## Related Repositories

- [jumpserver/jumpserver](https://github.com/jumpserver/jumpserver): The main JumpServer repository
- [jumpserver/koko](https://github.com/jumpserver/koko): Character protocol connector
- [jumpserver/lina](https://github.com/jumpserver/lina): Web admin console
- [jumpserver/luna](https://github.com/jumpserver/luna): Web terminal

## Contributing

Please report bugs and feature requests via [Issues](https://github.com/jumpserver/jumpserver/issues). Pull requests improving the build scripts and documentation are welcome.

## License

Copyright (c) 2014-2026 FIT2CLOUD, All rights reserved.

Licensed under the GNU General Public License version 3 (GPLv3), consistent with the [JumpServer main repository](https://github.com/jumpserver/jumpserver). See [LICENSE](LICENSE) for the full license text.
