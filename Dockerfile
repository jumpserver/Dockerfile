FROM centos:7

RUN yum -y install epel-release && \
    yum -y install gcc wget unzip nginx supervisor && \
    yum clean all

# 官方程序
RUN wget https://github.com/jumpserver/jumpserver/archive/master.zip -O /opt/jumpserver.zip && \
    wget https://github.com/jumpserver/coco/archive/master.zip -O /opt/coco.zip && \
    wget https://github.com/jumpserver/luna/releases/download/v1.0.0/luna.tar.gz -O /opt/luna.tar.gz && \
    cd /opt/ && \
    unzip coco.zip && mv coco{-master,} && \
    unzip jumpserver.zip && mv jumpserver{-master,} && \
    tar xzf luna.tar.gz && \
    rm -f /opt/coco.zip /opt/jumpserver.zip /opt/luna.tar.gz

# 基础依赖
RUN yum -y install $(cat /opt/jumpserver/requirements/rpm_requirements.txt) && \
    yum -y install $(cat /opt/coco/requirements/rpm_requirements.txt) && \
    yum clean all

# 准备python
RUN mkdir -p /opt/ && \
    wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz -O /opt/Python-3.6.1.tar.xz && \
    cd /opt/ && tar xf Python-3.6.1.tar.xz && cd ./Python-3.6.1 && \
    ./configure && \
    make && make install && \
    cd /opt/ && \
    rm -f /opt/Python-3.6.1.tar.xz && rm -rf /opt/Python-3.6.1

# python依赖
RUN python3 -m venv py3 && \
    source /opt/py3/bin/activate && \
    pip3 install --upgrade pip && \
    pip3 install -r /opt/jumpserver/requirements/requirements.txt && \
    pip3 install -r /opt/coco/requirements/requirements.txt

# 准备文件
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY jumpserver_conf.py /opt/jumpserver/config.py
COPY coco_conf.py /opt/coco/conf.py
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

VOLUME /opt/coco/keys /opt/jumpserver/data

EXPOSE 2222 80

ENTRYPOINT ["entrypoint.sh"]
