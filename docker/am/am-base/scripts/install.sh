#!/usr/bin/env bash
#
# Copyright 2019-2020 ForgeRock AS. All Rights Reserved
#

# Install AM using amster, and imports configuration files to create a base config, which is then placeholdered.
# The base config is deployed & placeholdered to expect an external DS for users, CTS, applications, policies and UMA.
set -o errexit
set -o pipefail

export CATALINA_PID=/home/forgerock/catalina.pid

wait-for-200() {
    while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' $1)" != "200" ]]; do
        sleep 1
        printf "."
    done
}

tomcat-running() {
    kill -0 "$1" > /dev/null 2>&1
}

get-authentication-sso-token() {
    curl -s "http://localhost:8080/am/json/realms/root/authenticate" \
    --request POST \
    --header "Content-Type: application/json" \
    --header "X-OpenAM-Username: amadmin" \
    --header "X-OpenAM-Password: password" \
    --header "Accept-API-Version: resource=2.0, protocol=1.0" \
    --data "{}" \
     | jq .tokenId -r
}

# This function performs additional configuration for external datastores that cannot be done via Amster.
configure-external-datastores() {
  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/services/baseurl" \
    -X PUT \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"defaults\": {
        \"source\": \"FIXED_VALUE\"
      }
    }")

  if [[ $status_code -ne 200 ]]; then
    echo -e "\e[31mFailed to set Base Url Service source attribute value.\e[0m"
    exit 1
  fi

  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/services/DataStoreService/config?_action=create" \
    -X POST \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"_id\" : \"application-store\",
      \"bindDN\" : \"cn=Directory Manager\",
      \"bindPassword\" : \"password\",
      \"affinityEnabled\" : false,
      \"useStartTLS\" : false,
      \"serverUrls\" : [ \"localhost:50636\" ],
      \"useSsl\" : true
    }")

  if [[ $status_code -ne 201 ]]; then
    echo -e "\e[31mFailed to create external application store.\e[0m"
    exit 1
  fi

  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/services/DataStoreService/config?_action=create" \
    -X POST \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"_id\" : \"policy-store\",
      \"bindDN\" : \"cn=Directory Manager\",
      \"bindPassword\" : \"password\",
      \"affinityEnabled\" : false,
      \"useStartTLS\" : false,
      \"serverUrls\" : [ \"localhost:50636\" ],
      \"useSsl\" : true
    }")

  if [[ $status_code -ne 201 ]]; then
    echo -e "\e[31mFailed to create external policy store.\e[0m"
    exit 1
  fi

  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/services/DataStoreService" \
    -X PUT \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"defaults\": {
        \"policyDataStoreId\": \"policy-store\",
        \"applicationDataStoreId\": \"application-store\"
      }
    }")

  if [[ $status_code -ne 200 ]]; then
    echo -e "\e[31mFailed to set external application/policy store.\e[0m"
    exit 1
  fi

  status_code=$(curl -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/realms/root/realm-config/services/DataStoreService?_action=create" \
    -X POST \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"applicationDataStoreId\": \"application-store\",
      \"policyDataStoreId\": \"policy-store\"
    }")

  if [[ $status_code -ne 201 ]]; then
    echo -e "\e[31mFailed to create root realm external datastore service.\e[0m"
    exit 1
  fi

  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/servers/server-default/properties/cts" \
    -X PUT \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"amconfig.org.forgerock.services.cts.store.common.section\": {
        \"org.forgerock.services.cts.store.location\": \"external\",
        \"org.forgerock.services.cts.store.root.suffix\": \"ou=tokens\",
        \"org.forgerock.services.cts.store.max.connections\": \"10\",
        \"org.forgerock.services.cts.store.page.size\": 0,
        \"org.forgerock.services.cts.store.vlv.page.size\": 1000
      },
      \"amconfig.org.forgerock.services.cts.store.external.section\": {
        \"org.forgerock.services.cts.store.ssl.enabled\": false,
        \"org.forgerock.services.cts.store.directory.name\": \"ds.localtest.me:1389\",
        \"org.forgerock.services.cts.store.loginid\": \"cn=Directory Manager\",
        \"org.forgerock.services.cts.store.password\": \"password\",
        \"org.forgerock.services.cts.store.heartbeat\": \"10\",
        \"org.forgerock.services.cts.store.affinity.enabled\": false
      }
    }")

  if [[ $status_code -ne 200 ]]; then
    echo -e "\e[31mFailed to set external CTS store.\e[0m"
    exit 1
  fi

  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/servers/server-default/properties/uma" \
    -X PUT \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"amconfig.org.forgerock.services.resourcesets.store.common.section\": {
        \"org.forgerock.services.resourcesets.store.location\": \"external\",
        \"org.forgerock.services.resourcesets.store.root.suffix\": \"ou=am-config\",
        \"org.forgerock.services.resourcesets.store.max.connections\": \"10\"
      },
      \"amconfig.org.forgerock.services.resourcesets.store.external.section\": {
        \"org.forgerock.services.resourcesets.store.ssl.enabled\": \"false\",
        \"org.forgerock.services.resourcesets.store.directory.name\": \"ds.localtest.me:1389\",
        \"org.forgerock.services.resourcesets.store.loginid\": \"cn=Directory Manager\",
        \"org.forgerock.services.resourcesets.store.password\": \"password\",
        \"org.forgerock.services.resourcesets.store.heartbeat\": \"10\"
      },
      \"amconfig.org.forgerock.services.umaaudit.store.common.section\": {
        \"org.forgerock.services.umaaudit.store.location\": \"external\",
        \"org.forgerock.services.umaaudit.store.root.suffix\": \"ou=am-config\",
        \"org.forgerock.services.umaaudit.store.max.connections\": \"10\"
      },
      \"amconfig.org.forgerock.services.umaaudit.store.external.section\": {
        \"org.forgerock.services.umaaudit.store.ssl.enabled\": \"false\",
        \"org.forgerock.services.umaaudit.store.directory.name\": \"ds.localtest.me:1389\",
        \"org.forgerock.services.umaaudit.store.loginid\": \"cn=Directory Manager\",
        \"org.forgerock.services.umaaudit.store.password\": \"password\",
        \"org.forgerock.services.umaaudit.store.heartbeat\": \"10\"
      },
      \"amconfig.org.forgerock.services.uma.pendingrequests.store.common.section\": {
        \"org.forgerock.services.uma.pendingrequests.store.location\": \"external\",
        \"org.forgerock.services.uma.pendingrequests.store.root.suffix\": \"ou=am-config\",
        \"org.forgerock.services.uma.pendingrequests.store.max.connections\": \"10\"
      },
      \"amconfig.org.forgerock.services.uma.pendingrequests.store.external.section\": {
        \"org.forgerock.services.uma.pendingrequests.store.ssl.enabled\": \"false\",
        \"org.forgerock.services.uma.pendingrequests.store.directory.name\": \"ds.localtest.me:1389\",
        \"org.forgerock.services.uma.pendingrequests.store.loginid\": \"cn=Directory Manager\",
        \"org.forgerock.services.uma.pendingrequests.store.password\": \"password\",
        \"org.forgerock.services.uma.pendingrequests.store.heartbeat\": \"10\"
      },
      \"amconfig.org.forgerock.services.uma.labels.store.common.section\": {
        \"org.forgerock.services.uma.labels.store.location\": \"external\",
        \"org.forgerock.services.uma.labels.store.root.suffix\": \"ou=am-config\",
        \"org.forgerock.services.uma.labels.store.max.connections\": \"2\"
      },
      \"amconfig.org.forgerock.services.uma.labels.store.external.section\": {
        \"org.forgerock.services.uma.labels.store.ssl.enabled\": \"false\",
        \"org.forgerock.services.uma.labels.store.directory.name\": \"ds.localtest.me:1389\",
        \"org.forgerock.services.uma.labels.store.loginid\": \"cn=Directory Manager\",
        \"org.forgerock.services.uma.labels.store.password\": \"password\",
        \"org.forgerock.services.uma.labels.store.heartbeat\": \"10\"
      }
    }")

  if [[ $status_code -ne 200 ]]; then
    echo -e "\e[31mFailed to set external UMA stores.\e[0m"
    exit 1
  fi

  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/services/oauth-oidc" \
    -X PUT \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"defaults\": {
        \"coreOAuth2Config\": {
          \"accessTokenModificationScript\": \"[Empty]\",
          \"accessTokenMayActScript\": \"[Empty]\",
          \"oidcMayActScript\": \"[Empty]\"
        },
        \"coreOIDCConfig\": {
          \"oidcClaimsScript\": \"[Empty]\"
        }
      }
    }")

  if [[ $status_code -ne 200 ]]; then
    echo -e "\e[31mFailed to remove OAuth2 Provider default scripts.\e[0m"
    exit 1
  fi
}

# This function sets the server siteName. Needed as the server siteName is not imported during Amster import.
configure-server-site() {
  status_code=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/am/json/global-config/servers/01/properties/general" \
    -X PUT \
    -H "Accept-API-Version: protocol=1.0,resource=1.0" \
    -H "Cookie: iPlanetDirectoryPro=${SSO_TOKEN}" \
    -H "Content-Type: application/json" \
    --data-binary "{
      \"amconfig.header.site\": {
        \"singleChoiceSite\": \"site1\"
      }
    }")

  if [[ $status_code -ne 200 ]]; then
    echo -e "\e[31mFailed to set server site.\e[0m"
    exit 1
  fi
}

export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.identity.sm.filebased_embedded_enabled=true"

catalina.sh start
CATALINA_PID_NUMBER=$(cat $CATALINA_PID)
tail -f /usr/local/tomcat/logs/catalina.out &

echo -n "Waiting for Tomcat to startup"
wait-for-200 http://localhost:8080/am/config/options.htm

cd /opt/amster

echo "Configuring with amster"
./amster scripts/00*

echo "Importing saved configuration with amster"
./amster scripts/01*

SSO_TOKEN=$(get-authentication-sso-token)

configure-external-datastores

configure-server-site

echo "stopping AM"

catalina.sh stop

echo "waiting for shutdown"
while tomcat-running "$CATALINA_PID_NUMBER"; do
	echo -n "."
	sleep 1
done
