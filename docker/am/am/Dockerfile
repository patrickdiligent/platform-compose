
FROM gcr.io/forgerock-io/am-base:7.1.0

USER root

RUN apt-get update && \
    apt-get install -y binutils wget unzip curl git && \
    apt-get clean

RUN mkdir -p /var/run/secrets && \
mkdir -p "$FORGEROCK_HOME"/shared && \
chown -R forgerock:root $FORGEROCK_HOME/shared

RUN rm /usr/local/tomcat/webapps/am/WEB-INF/classes/logback.xml

COPY --chown=forgerock:root plugins $CATALINA_HOME/webapps/am/WEB-INF/lib

# COPY --chown=forgerock:root security /var/run/secrets

USER forgerock

ENV FORGEROCK_HOME=/home/forgerock

# IAM-434: Preserves the native XUI code in a new location specifically for OAuth 2-related UI needs.
RUN cp -R /usr/local/tomcat/webapps/am/XUI /usr/local/tomcat/webapps/am/OAuth2_XUI
ENV CATALINA_USER_OPTS -Dorg.forgerock.am.oauth2.consent.xui_path=/OAuth2_XUI

COPY  --chown=forgerock:root config/ /home/forgerock/openam/config/

# Use a custom logback. Comment out if you want to use the default json logger.
# COPY --chown=forgerock:root logback.xml /usr/local/tomcat/webapps/am/WEB-INF/classes

COPY --chown=forgerock:root *.sh /home/forgerock/

WORKDIR /home/forgerock/openam

# # This lets the user see what FBC files have been modified
RUN git config --global user.email "cloud-deployment@forgerock.com" && \
    git config --global user.name "Cloud Deployment" && \
    git add . && \
    git commit -m "CDM file-based configuration overlay"

WORKDIR /home/forgerock
