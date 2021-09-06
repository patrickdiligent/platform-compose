#!/bin/bash

#
# Copyright 2019 ForgeRock AS. All Rights Reserved
#

# Logic for enabling continuous profiling for the AM jvm.

if [[ -z $JFR_OPTS ]] && [[ $ENABLE_JFR == true ]] ; then
    JFR_OPTS="-XX:+UnlockDiagnosticVMOptions -XX:+DebugNonSafepoints -XX:+FlightRecorder "
    JFR_OPTS="$JFR_OPTS -XX:StartFlightRecording=settings=default,dumponexit=true,filename=${JFR_OUTPUT_FILE:-recording.jfr},maxsize=1g"
    export JFR_OPTS
    echo "Java Flight Recorder profiling enabled"
    echo "JFR_OPTS: $JFR_OPTS"
fi
