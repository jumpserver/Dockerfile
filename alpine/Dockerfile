FROM centos:7
ARG nginxip=localhost
RUN curl -s http://${nginxip}/build.sh | bash
EXPOSE 2222 80 443
CMD ["/opt/start_jms.sh"]