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
docker run -p 8080:80 -p 2222:2222 jumpserver:0.5
OR
docker run -p 8080:80 -p 2222:2222 jumpserver:0.5-alpine
```

