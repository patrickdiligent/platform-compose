
ARG registry=sandbox

FROM ${registry}/java-11:latest

COPY --chown=forgerock:root DS-7.1.0.zip /tmp/opendj.zip

WORKDIR /opt
RUN apt-get update && apt-get upgrade -y && apt-get install -y unzip && \
unzip -q /tmp/opendj.zip && chown -R forgerock:root opendj && rm /tmp/opendj.zip

COPY --chown=forgerock:root template /opt/opendj/template
COPY --chown=forgerock:root setup.sh /opt/opendj
COPY --chown=forgerock:root docker-entrypoint.sh /opt/opendj

USER 11111
WORKDIR /opt/opendj
ENV PATH $PATH:/opt/jdk/bin:/opt/opendj/bin

RUN ./setup.sh

EXPOSE 4444
EXPOSE 1389
EXPOSE 1636
EXPOSE 8080
EXPOSE 8443
EXPOSE 8989

VOLUME /opt/opendj/secrets
VOLUME /opt/opendj/data

ENTRYPOINT ["/opt/opendj/docker-entrypoint.sh"]