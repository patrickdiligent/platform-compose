#
#  Copyright 2020 ForgeRock AS. All Rights Reserved
#
#  Use of this code requires a commercial software license with ForgeRock AS.
#  or with one of its affiliates. All use shall be exclusively subject
#  to such license between the licensee and ForgeRock AS.
#
FROM gcr.io/forgerock-io/java-11:latest
#
# Default install directory for IG. Override this to set a different location.
# 
ENV INSTALL_DIR /opt/ig

COPY --chown=forgerock:root IG.zip /tmp/ig.zip
COPY --chown=forgerock:root postgresql-42.2.19.jar /tmp/postgresql-42.2.19.jar
COPY --chown=forgerock:root gogetssl-rsa-dv-ca.crt /tmp/gogetssl-rsa-dv-ca.crt
COPY --chown=forgerock:root docker-entrypoint.sh /home/

WORKDIR /opt
RUN apt-get update && apt-get install -y unzip curl && unzip -q /tmp/ig.zip && mv /tmp/postgresql-42.2.19.jar /opt/identity-gateway/lib && mv /opt/identity-gateway $INSTALL_DIR

RUN keytool -import -alias gogetssl-root-ca -keystore /opt/jdk/lib/security/cacerts -storepass changeit -file /tmp/gogetssl-rsa-dv-ca.crt

#
# Default home for IG config. Override this to set a different location.
#
ENV IG_INSTANCE_DIR /var/ig
ENV WAIT_FOR_AM=

RUN mkdir -p "${IG_INSTANCE_DIR}" \
    && mkdir -p /home/shared \
    && chown -R forgerock:root "${IG_INSTANCE_DIR}" "${INSTALL_DIR}" /home/shared \
    && chmod -R g+rwx "${IG_INSTANCE_DIR}" "${INSTALL_DIR}"

USER 11111

CMD "/home/docker-entrypoint.sh"