#!/usr/bin/env sh
#
# Copyright 2019 ForgeRock AS. All Rights Reserved
#

BASE_CATALINA_OPTS="-server"

JPDA_OPTS="-agentlib:jdwp=transport=dt_socket,address=*:8000,server=y,suspend=n"

export CATALINA_OPTS="${BASE_CATALINA_OPTS} ${JPDA_OPTS}"

export CATALINA_PID=${CATALINA_HOME}/catalina.pid
