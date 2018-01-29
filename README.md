# Dockerfile

Jumpserver all in one Dockerfile

This project is only for Docker image build, this docker image we do not suggest you build in a product environment.

该项目仅仅是Jumpserver项目的docker镜像生成代码，我们不建议在生产环境下使用该镜像。

The main reasons are:

   - the database is in the docker too, and we suggest you use your own database by docker env.
   - lack of scalability 
   - NO HA plan
   - some unknown problems
   
主要原因是：

   - 数据库在docker内，建议通过docker的环境变量去使用外部数据库
   - 几乎丧失的横向扩展能力
   - 没有HA的解决方案
   - 未知的一些问题

## How to start
We provide two docker images, same function different size.

该项目提供两种docker镜像，同样的功能，只是镜像大小的区别。

```bash
docker run -p 8080:80 -p 2222:2222 jumpserver/allinone:v0.5-beta-2
OR
docker run -p 8080:80 -p 2222:2222 jumpserver/allinone:v0.5-beta-2-alpine
```

## Tips

1. You can use env to setup redis and mysql

```bash
docker run -p 8080:80 -p 2222:2222 \
 -e DB_HOST=xxx.xxx.xxx.xxx \
 -e DB_PORT=3306 \
 -e DB_USER=jumpserver \
 -e DB_PASSWORD=weakPassword \
 -e DB_NAME=jumpserver \
 -e REDIS_HOST=xxx.xxx.xxx.xxx \
 -e REDIS_PORT=6379 \
 jumpserver/allinone:v0.5-beta-2
```

You can choose which environment to use.

By default, we think you are using those db in docker, so please DO NOT set those HOST!!!

2. We already put all folders under /opt/, you can set a lot things with mount into it.

2.1 such link expose nginx to the Internet, mount your nginx config at /opt/nginx/conf.d/ .

You can set ssl or other things, because our nginx.conf is include /opt/nginx/conf.d/*.conf , you know what to do.

2.2 mount the mysql data folder for back up issue, /opt/mysql/data

2.3 also you can mount the source code folder, /opt/jumpserver, /opt/coco/, /opt/luna, so you can code outside and run in docker.

more docker tips you can find in this docker image.
