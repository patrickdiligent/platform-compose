#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${SCRIPTPATH}/../.env
source ${SCRIPTPATH}/realpath.sh

STAGE_DIR=$(abs_path ${SCRIPTPATH}/../../../config/stage)

echo "============ FBC Config ====================================="
FBC_DIR=$(abs_path ${SCRIPTPATH}/../../../config/fbc/config)
AM_DOCKER_DIR=$(abs_path ${SCRIPTPATH}/../../../docker/am/am/config)
echo "cleaning ${AM_DOCKER_DIR}"
rm -rf ${AM_DOCKER_DIR}
echo "Copying FBC from $FBC_DIR to ${AM_DOCKER_DIR}"
cp -r $FBC_DIR ${AM_DOCKER_DIR}
echo "============ Dynamic data (Amster) =========================="
AMSTER_DIR=$(abs_path ${SCRIPTPATH}/../../../config/amster)
IMPORT_DOCKER_DIR=$(abs_path ${SCRIPTPATH}/../../../docker/impexp/config)
echo "cleaning ${IMPORT_DOCKER_DIR}"
rm -rf ${IMPORT_DOCKER_DIR}
echo "Copying dynamic config from ${AMSTER_DIR} to ${IMPORT_DOCKER_DIR}"
cp -r $AMSTER_DIR ${IMPORT_DOCKER_DIR}

echo "============ IDM Config ====================================="
IDM_DOCKER_DIR=$(abs_path ${SCRIPTPATH}/../../../docker/idm/conf)
IDM_CONFIG_DIR=$(abs_path ${SCRIPTPATH}/../../../config/idm)
echo "cleaning ${IDM_DOCKER_DIR}"
rm -rf ${IDM_DOCKER_DIR}
echo "Copying IDM config from $IDM_CONFIG_DIR to ${IDM_DOCKER_DIR}"
cp -r $IDM_CONFIG_DIR ${IDM_DOCKER_DIR}