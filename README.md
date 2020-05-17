## Jumpserver Docker-Compose

```sh
git clone https://github.com/jumpserver/Dockerfile.git
cd Dockerfile
cat .env
docker-compose up
```

build
```sh
cd Dockerfile
cat .env
docker-compose -f docker-compose-build.yml up
```
## 说明

- .env 的变量 用在 docker-compose 里面, 可以自己看下
可能还有一些未能检测到的问题, 尽量自己调试一遍后再使用

> 如果自己编译, 可以在 docker-compose 的 environment: 处加入 Version: $Version , 取代 Dockerfile 的 ARG

## 外置 数据库 和 redis

- mysql server

```mysql
create database jumpserver default charset 'utf8' collate 'utf8_bin';
grant all on jumpserver.* to 'jumpserver'@'%' identified by 'weakPassword';
```

- 然后在 .env 里面定义 mysql 和 redis

```sh
cd Dockerfile
vi .env
docker-compose -f docker-compose-external.yml up
```
