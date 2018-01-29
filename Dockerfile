FROM centos:7
WORKDIR /opt/

COPY . /opt/install
RUN bash /opt/install/install.sh

ENV DB_HOST=127.0.0.1 DB_PORT=3306 DB_USER=jumpserver DB_PASSWORD=weakPassword DB_NAME=jumpserver
ENV REDIS_HOST=127.0.0.1 REDIS_PORT=6379

EXPOSE 2222 80
CMD ["/usr/bin/supervisord"]
