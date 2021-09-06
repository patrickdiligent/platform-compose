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
# Copyright 2021 ForgeRock AS.
#

# Build arg required for customer builds
ARG docker_tag=latest
ARG registry=sandbox

FROM ${registry}/amster:${docker_tag} as amster

FROM ${registry}/am-empty:${docker_tag} AS generator

USER 0
RUN apt-get update -y && \
    apt-get install -y git jq unzip 
USER 11111

ARG VERSION="7.1.0"

COPY --from=amster /opt/amster /opt/amster

COPY --chown=forgerock:root am-base/scripts/* /home/forgerock/
COPY --chown=forgerock:root am-base/boot.json am-base/serverconfig.xml /opt/templates/
COPY --chown=forgerock:root am-base/amster/ /opt/amster
COPY --chown=forgerock:root build/openam/Config-Upgrader-7.1.0.zip "$FORGEROCK_HOME"/config-placeholder.zip

RUN unzip -d "$FORGEROCK_HOME"/placeholder "$FORGEROCK_HOME"/config-placeholder.zip

WORKDIR $FORGEROCK_HOME
RUN ./install.sh

RUN ./placeholder-config.sh

WORKDIR $AM_HOME
RUN mkdir /tmp/am-home && \
    mv .homeVersion /tmp/am-home && \
    mv config /tmp/am-home && \
    rm -rf * && \
    mv /tmp/am-home/* . && \
    mv /tmp/am-home/.homeVersion . && \
    rm -rf /tmp/am-home
RUN ls -la .
RUN git config --global user.email "ci@forgerock.com" && \
    git config --global user.name "ForgeRock" && \
    git init && \
    git add . && \
    git commit --quiet -m "Base configuration"

FROM ${registry}/am-empty:${docker_tag} AS am-base

COPY --chown=forgerock:root --from=generator $AM_HOME/.git $AM_HOME/.git
COPY --chown=forgerock:root --from=generator $AM_HOME/.homeVersion $AM_HOME/.homeVersion
COPY --chown=forgerock:root --from=generator $AM_HOME/config $AM_HOME/config

COPY --chown=forgerock:root build/openam/AM-crypto-tool-7.1.0.jar "$FORGEROCK_HOME"/crypto-tool.jar
COPY --chown=forgerock:root am-base/docker-entrypoint.sh "$FORGEROCK_HOME"/
COPY --chown=forgerock:root am-base/scripts/import-pem-certs.sh "$FORGEROCK_HOME"/

CMD "$FORGEROCK_HOME/docker-entrypoint.sh"
