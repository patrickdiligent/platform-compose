#!/usr/bin/env bash
#
# Copyright (c) 2016-2017 ForgeRock AS. All rights reserved.
#

# If a command arg is not passed, default to import
ACTION="${1:-import}"

echo "amster action is $ACTION"


pause() {
    echo "Args are $# "

    echo "Container will now pause. You can exec into the container using kubectl exec to run export.sh"
    # Sleep forever, waiting for someone to exec into the container.
    while true
    do
        sleep 1000000 & wait
    done
}

# Without this chmod, Docker does not know the file is executable on Windows
chmod +x import.sh


# Extract amster version for commons parameter to modify configs
echo "Extracting amster version"
VER=$(./amster --version)
echo "Amster version output is: '${VER}'"
[[ "$VER" =~ ([0-9].[0-9].[0-9](\.[0-9]*)?-([a-zA-Z0-9]+|([-a-zA-Z0-9]+)?SNAPSHOT|RC[0-9]+|M[0-9]+)|[0-9].[0-9].[0-9](\.[0-9]*)?) ]]
VERSION=${BASH_REMATCH[1]}
echo "Amster version is: '${VERSION}'"
export VERSION

case $ACTION  in
pause)
    pause
    ;;
export)
    ./export.sh
    sleep infinity
    ;;
export-exit)
    # Like export - but exit immediately.
    # You must run another container after this
    # that will save the exported files.
    ./export.sh
    ;;
import)
    # invoke amster install.
    ./import.sh
    ;;
import-export)
    ./import.sh
    ./export.sh
    sleep infinity
    ;;
upload)
    # Like import - but waits for files to be uploaded to config/upload
    ./import.sh upload
    ;;
*)
   exec "$@"
esac
