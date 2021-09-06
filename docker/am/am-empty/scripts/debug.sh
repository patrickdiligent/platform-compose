#!/bin/bash

#
# Copyright 2019 ForgeRock AS. All Rights Reserved
#

# Logic for determining debugging mode for Tomcat

JPDA_TRANSPORT=${JPDA_TRANSPORT:-dt_socket}

if [ -z "$JPDA_DEBUG" ] && [ ! -z "$JPDA_ADDRESS" ]; then
    export JPDA_DEBUG="jpda"

    echo "Tomcat Debugging enabled"
    echo "JPDA_TRANSPORT: $JPDA_TRANSPORT"
    echo "JPDA_ADDRESS: $JPDA_ADDRESS"
fi


