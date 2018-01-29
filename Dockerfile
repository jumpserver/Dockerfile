FROM centos:7
RUN yum update -y && yum install epel-release -y && yum update -y && yum install wget unzip epel-release nginx sqlite-devel xz gcc automake zlib-devel openssl-devel redis mariadb mariadb-devel mariadb-server -y
WORKDIR /opt/
RUN wget https://github.com/jumpserver/jumpserver/archive/master.zip -O /opt/jumpserver.zip
RUN wget https://github.com/jumpserver/coco/archive/dev.zip -O /opt/coco.zip
RUN wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz -O /opt/Python-3.6.1.tar.xz
RUN wget https://github.com/jumpserver/luna/releases/download/0.5-beta-2/luna.tar.gz -O /opt/luna.tar.gz
RUN tar xf Python-3.6.1.tar.xz  && cd Python-3.6.1 && ./configure && make && make install
RUN unzip coco.zip && unzip jumpserver.zip
RUN yum -y install $(cat /opt/jumpserver-master/requirements/rpm_requirements.txt) 
RUN python3 -m venv py3
RUN source /opt/py3/bin/activate && pip install -r /opt/jumpserver-master/requirements/requirements.txt &&  pip install -r /opt/coco-dev/requirements/requirements.txt 
RUN tar xzf /opt/luna.tar.gz
RUN yum install supervisor -y
RUN mkdir -p /opt/nginx/log && chmod 777 /opt/nginx/log/
RUN mkdir -p /opt/mysql/log /opt/mysql/data /opt/mysql/plugin 
RUN ln -s /opt/mysql/mysql.sock  /var/lib/mysql/mysql.sock
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY mysql.cnf /etc/my.cnf
COPY errmsg.sys /opt/mysql/share/mysql/errmsg.sys
RUN mysql_install_db
COPY mysql_security.sql /opt/mysql/
RUN chown -R mysql:mysql /opt/mysql
COPY jumpserver_conf.py /opt/jumpserver-master/config.py
RUN /usr/bin/mysqld_safe --default-file=/etc/my.cnf 
COPY ./security.sh /opt/security.sh
EXPOSE 2222 80
CMD ["/usr/bin/supervisord"]
