## Jumpserver Docker-Compose

```
$ git clone https://github.com/wojiushixiaobai/docker-compose.git
$ cd docker-compose
$ cat .env
$ docker-compose up
```

build
```
$ cd docker-compose
$ cat .env
$ docker-compose -f docker-compose-build.yml up
```
## 说明

- .env 的变量 用在 docker-compose 里面, 可以自己看下
可能还有一些未能检测到的问题, 尽量自己调试一遍后再使用

> 如果自己编译, 可以在 docker-compose 的 environment: 处加入 Version: $Version , 取代 Dockerfile 的 ARG
