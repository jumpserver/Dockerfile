FROM centos:7
RUN curl -s https://raw.githubusercontent.com/jumpserver/Dockerfile/mysql/alpine/build.sh | bash
EXPOSE 2222 80 443
CMD ["/opt/start_jms.sh"]
