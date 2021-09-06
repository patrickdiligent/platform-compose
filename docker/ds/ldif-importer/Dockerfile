ARG registry=sandbox
ARG docker_tag=7.1.0
FROM ${registry}/ds-base:${docker_tag}

USER 0
RUN apt-get update -y && apt-get install -y curl
USER 11111

COPY --chown=forgerock:root start.sh /opt/opendj
COPY --chown=forgerock:root ds-passwords.sh /opt/opendj

ENTRYPOINT /opt/opendj/start.sh
