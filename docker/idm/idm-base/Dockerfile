ARG registry=sandbox

FROM ${registry}/java-11:latest

# ttf-dejavu font needed by Flowable workflow engine
RUN apt-get update && \
    apt-get install -y ttf-dejavu unzip

COPY --chown=forgerock:root IDM-7.1.0.zip /tmp/openidm.zip
RUN unzip -q -d /opt /tmp/openidm.zip && \
   rm /tmp/openidm.zip && \
   chown -R forgerock:root /opt/openidm

WORKDIR /opt/openidm

EXPOSE 8080

USER 11111

ENTRYPOINT ["/opt/openidm/bin/docker-entrypoint.sh", "openidm"]