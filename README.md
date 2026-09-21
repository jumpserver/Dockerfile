<p align="center">
  <a href="https://jumpserver.org"><img src="https://download.jumpserver.org/images/jumpserver-logo.svg" alt="JumpServer" width="300" /></a>
</p>
<h3 align="center">JumpServer all-in-one 部署</h3>
<p align="center">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/jumpserver/Dockerfile" alt="License: GPLv3"></a>
  <a href="https://hub.docker.com/u/jumpserver"><img src="https://img.shields.io/docker/pulls/jumpserver/jms_all.svg" alt="Codacy"></a>
</p>

--------------------------

## JumpServer all-in-one 快速部署

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

**初始账号**
```bash
默认账号: admin
默认密码: ChangeMe
```
