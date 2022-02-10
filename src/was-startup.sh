#!/bin/bash

gomplate -f logrotate-was.tmpl -o /etc/logrotate.d/logrotate-was
echo -e "0\t0\t*\t*\t*\tlogrotate -f /etc/logrotate.d/logrotate-was" > /etc/crontabs/root

export SPRING_GC=${SPRING_GC:-"-XX:${JAVA_GC_TYPE} -XX:NewRatio=${JAVA_GC_NEWRATIO} ${JAVA_GC_EXTRA} \
     -XX:+PrintGCDetails -XX:+PrintGCDateStamps \
     -XX:+PrintGCDetails -XX:+PrintGCDateStamps -verbose:gc -Xloggc:${SERVER_TOMCAT_ACCESS_DIRECTORY}/gc-%t.log \
     -XX:+UseGCLogFileRotation -XX:GCLogFileSize=${JAVA_GC_LOGFILESIZE} -XX:NumberOfGCLogFiles=${JAVA_GC_NUMBEROFGCLOGFILES} \
     -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${SERVER_TOMCAT_ACCESS_DIRECTORY} "}

export SPRING_SERVER_TOMCAT_ENV=${SPRING_SERVER_TOMCAT_ENV:-"-Dserver.tomcat.accept-count=${SERVER_TOMCAT_ACCEPT_COUNT} -Dserver.tomcat.max-connection
-Dserver.tomcat.threads.max=${SERVER_TOMCAT_THREADS_MAX} -Dserver.tomcat.max-threads=${SERVER_TOMCAT_THREADS_MAX} \
-Dserver.tomcat.threads.min-spare=${SERVER_TOMCAT_THREADS_MIN_SPARE} -Dserver.tomcat.min-spare-threads=${SERVER_TOMCAT_THREADS_MIN_SPARE} \
-Dserver.tomcat.accesslog.directory=${SERVER_TOMCAT_ACCESS_DIRECTORY} -Dserver.tomcat.accesslog.max-days=${SERVER_TOMCAT_ACCESSLOG_MAX_DAYS} \
-Dserver.tomcat.accesslog.enabled=${SERVER_TOMCAT_ACCESSLOG_ENABLED} ${SERVER_TOMCAT_EXTRA_OPTIONS}  "}

java ${SPRING_GC} \
     ${SPRING_SERVER_TOMCAT_ENV} -Dserver.tomcat.accesslog.pattern="${SERVER_TOMCAT_ACCESSLOG_PATTERN}" \
     -jar -server -Xms${SPRING_XMS} -Xmx${SPRING_XMX} \
     -Dspring.profiles.active=${SPRING_PROFILE} \
     -Djava.net.preferIPv4Stack=true -Dfile.encoding=utf8 ${SPRING_FILE} ${JAVA_EXTRA_OPTION}  >> ${SERVER_TOMCAT_LOG}  2>&1

exec crond -f -L /var/log/cron.log

