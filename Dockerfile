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
RUN source /opt/py3/bin/activate
RUN pip install -r /opt/jumpserver-master/requirements/requirements.txt
RUN pip install -r /opt/coco-dev/requirements/requirements.txt 
