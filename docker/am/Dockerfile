FROM gcr.io/forgerock-io/am-cdk:7.4.0

ARG CONFIG_PROFILE=cdk
COPY  --chown=forgerock:root config/services /home/forgerock/openam/config/services

COPY --chown=forgerock:root *.sh /home/forgerock/

WORKDIR /home/forgerock

# If you want to debug AM uncomment these lines:
#ENV JPDA_TRANSPORT=dt_socket
#ENV JPDA_ADDRESS *:9009
