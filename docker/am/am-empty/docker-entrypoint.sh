#!/bin/bash

#
# Copyright 2019-2020 ForgeRock AS. All Rights Reserved
#

. $FORGEROCK_HOME/debug.sh
. $FORGEROCK_HOME/profiling.sh

CATALINA_OPTS="$CATALINA_OPTS $AM_CONTAINER_JVM_ARGS $CATALINA_USER_OPTS $JFR_OPTS"

echo "Starting tomcat with opts: ${CATALINA_OPTS}"
exec $CATALINA_HOME/bin/catalina.sh $JPDA_DEBUG run
