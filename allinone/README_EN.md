# Dockerfile

This is the Dockerfile for JumpServer all-in-one deployment, a Docker image generation code for the JumpServer all-in-one deployment method.

## How to start

When migrating or upgrading the environment, please ensure that the SECRET_KEY is consistent with the previous settings and not randomly generated. Otherwise, all encrypted fields in the database cannot be decrypted.

### Quick start

**Note: The all-in-one deployment method does not support Client-related features. It only supports usage on a pure B/S architecture web interface.**

```sh
docker volume create jsdata
docker run --name jms_all \
     -e SECRET_KEY=PleaseChangeMe \
     -e BOOTSTRAP_TOKEN=PleaseChangeMe \
     -v jsdata:/opt/data \
     -p 2222:2222 \
     -p 80:80 jumpserver/jms_all
```

### Standard start

Using an external MySQL database and Redis:

  - The external database requires MariaDB version 10.6 or higher, or PostgresSQL 13;
  - The external Redis requires Redis version 6.2 or higher.

```sh
# To deploy MySQL yourself, refer to (https://docs.jumpserver.org/zh/master/install/setup_by_lb/#mysql)
# Create a MySQL user and grant privileges, please replace nu4x599Wq7u0Bn8EABh3J91G with your own password
mysql -u root -p
```

```mysql
create database jumpserver default charset 'utf8';
create user 'jumpserver'@'%' identified by 'nu4x599Wq7u0Bn8EABh3J91G';
grant all on jumpserver.* to 'jumpserver'@'%';
flush privileges;
```

```sh
# To deploy Redis yourself, refer to (https://docs.jumpserver.org/zh/master/install/setup_by_lb/#redis)
```

**设置环境变量：**

	-	SECRET_KEY = xxxxx                # Generate a random string yourself, do not include special characters, length recommended to be at least 50
	-	BOOTSTRAP_TOKEN = xxxxx           # Generate a random string yourself, do not include special characters, length recommended to be at least 24
	-	LOG_LEVEL = ERROR                 # Log level, set to DEBUG for testing environments
	-	DB_ENGINE = mysql                 # Use MySQL database
	-	DB_HOST = mysql_host              # MySQL database IP address
	-	DB_PORT = 3306                    # MySQL database port
	-	DB_USER = xxx                     # MySQL database username
	-	DB_PASSWORD = xxxx                # MySQL database password
	-	DB_NAME = jumpserver              # Database name used by JumpServer
	-	REDIS_HOST = redis_host           # Use Redis for caching
	-	REDIS_PORT = 6379                 # Redis server port
	-	REDIS_PASSWORD = xxxx             # Redis authentication password
	-	VOLUME /opt/jumpserver/data       # Core persistent directory, stores video logs
	-	VOLUME /opt/koko/data             # Koko persistent directory
	-	VOLUME /opt/lion/data             # Lion persistent directory
	-	VOLUME /opt/chen/data             # Chen persistent directory
	-	VOLUME /var/log/nginx             # Nginx log persistent directory
	-	VOLUME /opt/download              # APPLETS file persistent directory (files required for application publishing)


Note: Be sure to record the information you set above, as it will be needed again during upgrades

**启动 JumpServer**
```bash
docker volume create jsdata

docker run --name jms_all -d \
  -p 80:80 \
  -p 2222:2222 \
  -e SECRET_KEY=xxxxxx \
  -e BOOTSTRAP_TOKEN=xxxxxx \
  -e LOG_LEVEL=INFO \
  -e DB_HOST=192.168.x.x \
  -e DB_PORT=3306 \
  -e DB_USER=jumpserver \
  -e DB_PASSWORD=weakPassword \
  -e DB_NAME=jumpserver \
  -e REDIS_HOST=192.168.x.x \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=weakPassword \
  --privileged=true \
  -v jsdata:/opt/data \
  jumpserver/jms_all:v4.1.0
```

**Upgrade**
```bash
# Check the defined JumpServer configurations
docker exec -it jms_all env

# Stop JumpServer
docker stop jms_all

# Backup the database, replace DB-xxx with the values retrieved from the docker exec -it jms_all env command
mysqldump -h$DB_HOST -p$DB_PORT -u$DB_USER -p$DB_PASSWORD $DB_NAME > /opt/jumpserver-<version>.sql
# Example: mysqldump -h192.168.100.11 -p3306 -ujumpserver -pnu4x599Wq7u0Bn8EABh3J91G jumpserver > /opt/jumpserver-v2.12.0.sql

# Pull the new version of the image
docker pull jumpserver/jms_all:v4.1.0

# Remove the old version container
docker rm jms_all

# Restart with the new version
```

**Initial Account**
```bash
Default username: admin
Default password: ChangeMe
```