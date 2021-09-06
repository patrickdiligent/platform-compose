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

ARG registry=sandbox

FROM ${registry}/java-11:latest

ENV FORGEROCK_HOME /home/forgerock

# Install a number of utilities. Not all containers will need all of these - but these are quite small in size.
# dnsutils for dig (dns diagnostics)
# iputils-ping - ping command
RUN apt-get update && apt-get upgrade -y && apt-get install -y unzip curl dnsutils iputils-ping sysstat

COPY build/amster /build

RUN mkdir -p /opt/amster && \
    cp  -R /build/* /opt/amster && \
    chown -R forgerock:root /opt && \
    rm -rf /build/amster

COPY amster/*.sh /opt/amster/
COPY amster/*.sh /usr/local/bin/

# git is added to the container so we can optionally execute git commit, git push, etc.
RUN chmod 775 /opt/amster/amster \
    && chown -R forgerock /opt

WORKDIR /opt/amster

USER 11111

ENTRYPOINT ["/opt/amster/docker-entrypoint.sh"]

CMD ["configure"]
