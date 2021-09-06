#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${SCRIPTPATH}/../.env
source ${SCRIPTPATH}/realpath.sh

AM_CONTAINER=${AM_CONTAINER:-am.sdx.local}
EXPORTER_CONTAINER=${EXPORTER_CONTAINER:-impexp.sdx.local}
IDM_CONTAINER=${IDM_CONTAINER:-idm.sdx.local}

STAGE_DIR=$(abs_path ${SCRIPTPATH}/../../../config/stage)
echo "Clearing the staging area $STAGE_DIR"
rm -rf ${STAGE_DIR}/fbc.tar
rm -rf ${STAGE_DIR}/amster
rm -rf ${STAGE_DIR}/idm

echo "=== Exporting AM's FBC into shared mounted volume (staging area)"
docker exec -it ${AM_CONTAINER} /home/forgerock/export-diff.sh /home/forgerock/shared/fbc.tar

echo "=== Amster export of dynamic data"
docker exec -it ${EXPORTER_CONTAINER} /opt/amster/export.sh >> /dev/null 2>&1
echo "Copying Amster export into staging area"
docker cp ${EXPORTER_CONTAINER}:/var/tmp/amster/realms/root/ ${STAGE_DIR}/amster

echo '=== Exportin IDM configuration'
docker cp ${IDM_CONTAINER}:/opt/openidm/conf $STAGE_DIR/idm

echo
echo "--- Export complete ==> run config-save.sh to update the git versioned configuration"
echo "then init-config.sh followed by 'docker-compose build' to build the custom images."