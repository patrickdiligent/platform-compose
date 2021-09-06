#
# The contents of this file are subject to the terms of the Common Development and
# Distribution License (the License). You may not use this file except in compliance with the
# License.
#
# You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
# specific language governing permission and limitations under the License.
#
# When distributing Covered Software, include this CDDL Header Notice in each file and include
# the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
# Header, with the fields enclosed by brackets [] replaced by your own identifying
# information: "Portions Copyright [year] [name of copyright owner]".
#
# Copyright 2020 ForgeRock AS.
#
FROM tomcat:9-jdk11-adoptopenjdk-hotspot AS base

RUN apt-get update -y && \
    apt-get install -y binutils wget unzip

# This installs the GCP stack driver profiler.
RUN mkdir -p /opt/cprof && \
     wget -q -O- https://storage.googleapis.com/cloud-profiler/java/latest/profiler_java_agent.tar.gz \
     | tar xzv -C /opt/cprof

# Installs the async-profiler
RUN mkdir -p /opt/async-profiler && \
    wget -q -O-  https://github.com/jvm-profiling-tools/async-profiler/releases/download/v1.5/async-profiler-1.5-linux-x64.tar.gz \
    | tar xzv -C /opt/async-profiler

ADD /build/openam/AM-7.1.0.war "$CATALINA_HOME"/webapps/openam.war
RUN unzip -q "$CATALINA_HOME"/webapps/openam.war -d "$CATALINA_HOME"/webapps/am && \
    rm "$CATALINA_HOME"/webapps/openam.war

RUN rm -rf "$CATALINA_HOME"/webapps/am/click
RUN rm -rf "$CATALINA_HOME"/webapps/am/assets/lib/yui
RUN rm "$CATALINA_HOME"/webapps/am/config/defaultSummary.htm
RUN rm "$CATALINA_HOME"/webapps/am/config/options.htm
RUN rm "$CATALINA_HOME"/webapps/am/config/index.html
RUN rm -rf "$CATALINA_HOME"/webapps/am/config/upgrade
RUN rm -rf "$CATALINA_HOME"/webapps/am/config/wizard

COPY am-empty/logback.xml "$CATALINA_HOME"/webapps/am/WEB-INF/classes

FROM tomcat:9-jdk11-adoptopenjdk-hotspot AS am-tomcat

ENV FORGEROCK_HOME=/home/forgerock

# The openam context directory
ENV AM_HOME=$FORGEROCK_HOME/openam

ENV CATALINA_OPTS="-server \
    -Dcom.sun.services.debug.mergeall=on \
    -Dcom.sun.identity.configuration.directory=$AM_HOME \
    -Dcom.iplanet.services.stats.state=off \
    -Dcom.sun.identity.sm.sms_object_filebased_enabled=true \
    -Dorg.forgerock.donotupgrade=true \
    -DtomcatAccessLogDir=/proc/self/fd -DtomcatAccessLogFile=1"

ENV AM_CONTAINER_JVM_ARGS="-XX:MaxRAMPercentage=75 \
    -XX:InitialRAMPercentage=75 \
    -XX:MaxTenuringThreshold=1 \
    -Djava.security.egd=file:/dev/urandom"

RUN groupadd -g 11111 forgerock && \
    useradd -c "ForgeRock user" -m -d $FORGEROCK_HOME -u 11111 -g 11111 -G root forgerock

RUN apt-get update -y && \
    apt-get install -y curl && \
    apt-get clean

RUN chown -R forgerock:root "$CATALINA_HOME"

USER 11111

RUN mkdir -p $AM_HOME/config
RUN chmod -R g+wx $AM_HOME

RUN rm -rf "$CATALINA_HOME"/webapps/*

COPY --from=base --chown=forgerock:root /opt/cprof /opt/cprof
COPY --from=base --chown=forgerock:root /opt/async-profiler /opt/async-profiler
COPY --from=base --chown=forgerock:root "$CATALINA_HOME"/webapps/am "$CATALINA_HOME"/webapps/am

COPY --chown=forgerock:root am-empty/tomcat/*.xml "$CATALINA_HOME"/conf/
COPY --chown=forgerock:root am-empty/scripts/*.sh "$FORGEROCK_HOME"/
COPY --chown=forgerock:root am-empty/docker-entrypoint.sh "$FORGEROCK_HOME"/

EXPOSE 8080

CMD "$FORGEROCK_HOME/docker-entrypoint.sh"
