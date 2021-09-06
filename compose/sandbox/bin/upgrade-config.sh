#!/usr/bin/env bash
# Run the am-config upgrade script based on the rules found in /config/am-upgrader-rules
#

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source ${SCRIPTPATH}/../.env
source ${SCRIPTPATH}/realpath.sh

IMAGE=${REGISTRY}/amupgrade

CONFIG_DIR=$(abs_path ${SCRIPTPATH}/../../../config/fbc)
RULES_DIR=$(abs_path ${SCRIPTPATH}/../../../config/am-upgrader-rules)

echo "Using rules in $RULES_DIR"
echo "Processing config in $CONFIG_DIR"

# Command inside the docker image
UPGRADER="/home/forgerock/amupgrade/amupgrade"
CMD="$UPGRADER --inputConfig /am-config/config/services --output /am-config/config/services --fileBasedMode --prettyArrays --clean false --baseDn ou=am-config \$(ls /rules/*)"

# Run the upgrader in docker. The config files and rules are mounted on the container. After exit, the config in $CONFIG will be upgraded/placedholdered
echo "===== Upgrading static config (FBC)"
docker run --rm --user :$UID --volume "$CONFIG_DIR":/am-config --volume "$RULES_DIR:/rules" "$IMAGE" sh  -c "$CMD"

echo "===== Ugrading Amster dynamic config (OAuth clients, ...)"

CONFIG_DIR=$(abs_path ${SCRIPTPATH}/../../../config/amster)
cd $CONFIG_DIR

type jq > /dev/null 2>&1
[ ! "$?" -eq 0 ] && echo && echo "!!!!!Please install 'jq' to update JSON files ('brew install jq' on MacOs}" && exit

echo "=== OAuth2 Clients"
echo "= end-user-ui"
FILE="OAuth2Clients/end-user-ui.json"
jq '.data.coreOAuth2ClientConfig.redirectionUris=[ "https://&{fqdn}/enduser/appAuthHelperRedirect.html", "https://&{fqdn}/enduser/sessionCheck.html", "https://&{fqdn}/postman" ] | del(.data.coreOAuth2ClientConfig["userpassword-encrypted"]) | .data.coreOAuth2ClientConfig.userpassword="password"' ${FILE} >  ${FILE}.new; mv ${FILE}.new  ${FILE}

echo "= idm-admin-ui"
FILE="OAuth2Clients/idm-admin-ui.json"
jq '.data.coreOAuth2ClientConfig.redirectionUris=[ "https://&{fqdn}/platform/appAuthHelperRedirect.html", "https://&{fqdn}/platform/sessionCheck.html", "https://&{fqdn}/admin/appAuthHelperRedirect.html", "https://&{fqdn}/admin/sessionCheck.html", "https://&{fqdn}/postman" ] | del(.data.coreOAuth2ClientConfig["userpassword-encrypted"]) | .data.coreOAuth2ClientConfig.userpassword="password"' ${FILE} >  ${FILE}.new; mv ${FILE}.new ${FILE}


PASSWORDS=(
    "idm-provisioning:password"
    "idm-resource-server:password"
    "IGClient:password"
    "oauth2:password"
    "PatsMobileApp:password"
    "resource-server:password"
    "test:password"
)

for client in "${PASSWORDS[@]}"; do
    CLIENT=${client%%:*}
    PASSWORD=${client#*:}
    echo "= $CLIENT"
    FILE="OAuth2Clients/$CLIENT.json"
    jq 'del(.data.coreOAuth2ClientConfig["userpassword-encrypted"]) | .data.coreOAuth2ClientConfig.userpassword="'$PASSWORD'"' ${FILE} >  ${FILE}.new; mv ${FILE}.new ${FILE}
done

echo "=== IG agents"

PASSWORDS=(
    "ig_agent:password"
    "ig-agent:password"
)

for agent in "${PASSWORDS[@]}"; do
    AGENT=${agent%%:*}
    PASSWORD=${agent#*:}
    echo "= $AGENT"
    FILE="IdentityGatewayAgents/$AGENT.json"
    jq 'del(.data["userpassword-encrypted"]) | .data.userpassword="'$PASSWORD'"' ${FILE} >  ${FILE}.new; mv ${FILE}.new ${FILE}
done
