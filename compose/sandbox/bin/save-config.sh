#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${SCRIPTPATH}/../.env
source ${SCRIPTPATH}/realpath.sh

AM_CONTAINER=${AM_CONTAINER:-am.sdx.local}
EXPORTER_CONTAINER=${EXPORTER_CONTAINER:-impexp.sdx.local}
STAGE_DIR=$(abs_path ${SCRIPTPATH}/../../../config/stage)

echo "============ FBC Config ===================================="
STAGE_DIR=$(abs_path ${SCRIPTPATH}/../../../config/stage)
FBC_DIR=$(abs_path ${SCRIPTPATH}/../../../config/fbc)
cd ${FBC_DIR}
echo "expanding FBC changes from $STAGE_DIR/fbc.tar into ${FBC_DIR}"
tar xvf ${STAGE_DIR}/fbc.tar

echo "============ Dynamic data (Amster) ========================="
AMSTER_DIR=$(abs_path ${SCRIPTPATH}/../../../config/amster)
echo "cleaning ${AMSTER_DIR}"
rm -rf ${AMSTER_DIR}/*
echo "Copying dynamic config from ${STAGE_DIR}/amster"
cp -r ${STAGE_DIR}/amster/* ${AMSTER_DIR} 

echo "============ IDM Configuration ========================="
IDM_DIR=$(abs_path ${SCRIPTPATH}/../../../config/idm)
echo "cleaning ${IDM_DIR}"
rm -rf ${IDM_DIR}/*
echo "Copying IDM config from ${STAGE_DIR/idm}"
cp -r ${STAGE_DIR}/idm/* ${IDM_DIR} 

echo "============ AM config update with placeholders ============="
${SCRIPTPATH}/upgrade-config.sh
