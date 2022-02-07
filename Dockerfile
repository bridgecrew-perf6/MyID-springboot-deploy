FROM    openjdk:8-jdk-alpine

ENV     TZ=Asia/Seoul
ENV     APP_START_HOME=/app
ENV     SPRING_FILE=ROOT.jar
ENV     SPRING_FILE_DIRECTORY=${APP_START_HOME}/data
ENV     SPRING_PROFILE=live
ENV     SPRING_XMS=1g
ENV     SPRING_XMX=1g
ENV     SPRING_LOGROTATE_DATE=7
ENV     SPRING_HEALTH_CHECK=localhost:8080/healthCheck

## SPRING TOMCAT Properties https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-application-properties.html
ENV     SERVER_TOMCAT_ACCEPT_COUNT=10
ENV     SERVER_TOMCAT_ACCESS_DIRECTORY=${APP_START_HOME}/logs/
ENV     SERVER_TOMCAT_ACCESSLOG_ENABLED=true
ENV     SERVER_TOMCAT_ACCESSLOG_PATTERN=combined
ENV     SERVER_TOMCAT_ACCESSLOG_MAX_DAYS=14
ENV     SERVER_TOMCAT_MAX_CONNECTIONS=10000
ENV     SERVER_TOMCAT_THREADS_MIN_SPARE=25
ENV     SERVER_TOMCAT_THREADS_MAX=600
ENV     SERVER_TOMCAT_LOG=${SERVER_TOMCAT_ACCESS_DIRECTORY}/catalina.out

ENV     JAVA_GC_NEWRATIO=7
ENV     JAVA_GC_LOGFILESIZE=50m
ENV     JAVA_GC_NUMBEROFGCLOGFILES=5
ENV     JAVA_GC_TYPE="+UseG1GC"

COPY    src/was-startup.sh /bin/was-startup.sh
COPY    src/logrotate-was.tmpl /tmp/logrotate-was.tmpl
WORKDIR ${APP_START_HOME}

RUN     mkdir -p /usr/share/fonts/NanumFont \
&&      mkdir -p ${SERVER_TOMCAT_ACCESS_DIRECTORY}/gc/ \
&&      apk add --no-cache --virtual .build-deps shadow \
&&      apk del .build-deps \
&&      apk add --no-cache curl tzdata logrotate gomplate bash \
&&      chmod 700 /bin/was-startup.sh \
&&      rm -rf /var/cache/apk/*


HEALTHCHECK --interval=1m --timeout=10s --start-period=30s \
  CMD curl -f http://${SPRING_HEALTH_CHECK} || exit 1



CMD     ["sh","-x","/bin/was-startup.sh"]
