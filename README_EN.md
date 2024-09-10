
<p align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>
</p>
<h3 align="center">A Better Bastion Host for Multi-Cloud Environments</h3>

<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
  <a href="https://hub.docker.com/u/jumpserver"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Codacy"></a>
  <a href="https://github.com/jumpserver/Dockerfile/commits"><img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/jumpserver/Dockerfile.svg" /></a>
  <a href="https://github.com/jumpserver/Dockerfile"><img src="https://img.shields.io/github/stars/jumpserver/Dockerfile?color=%231890FF&style=flat-square" alt="Stars"></a>
</p>

--------------------------

## all-in-one Quick Deployment
This can be used for testing environments. For production environments, it is recommended to use the standard deployment.

```sh
docker volume create jsdata &> /dev/null
docker volume create pgdata &> /dev/null
docker run --name jms_all \
     -e SECRET_KEY=PleaseChangeMe \
     -e BOOTSTRAP_TOKEN=PleaseChangeMe \
     -v jsdata:/opt/data \
     -v pgdata:/var/lib/postgresql \
     -p 2222:2222 \
     -p 80:80 jumpserver/jms_all
```

For more details, see the all-in-one [README](allinone).

## Standard Deployment

Please use the JumpServer installer for deployment.

https://docs.jumpserver.org/zh/v3/quick_start/

## Cluster Deployment

JumpServer supports deployment using Swarm, but it is not highly recommended for production environments unless you are familiar with it.

For more details, see the Swarm [README](swarm).
