#!/bin/sh
#
# The contents of this file are subject to the terms of the Common Development and
# Distribution License (the License). You may not use this file except in compliance with the
# License.
#
# You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
# specific language governing permission and limitations under the License.
#
# When distributing Covered Software, include this CDDL Header Notice in each file and include
# the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
# Header, with the fields enclosed by brackets [] replaced by your own identifying
# information: "Portions Copyright [year] [name of copyright owner]".
#
# Copyright 2019-2021 ForgeRock AS.
#
set -eux

#rm -f template/config/tools.properties
# cp -r samples/docker/* .
#rm -rf -- README* bat *.zip *.png *.bat setup.sh

./setup --serverId                docker \
        --hostname                localhost \
        --deploymentKeyPassword   password \
        --rootUserPassword        password \
        --adminConnectorPort      4444 \
        --ldapPort                1389 \
        --enableStartTls \
        --ldapsPort               1636 \
        --httpPort                8080 \
        --httpsPort               8443 \
        --replicationPort         8989 \
        --rootUserDn              uid=admin \
        --monitorUserDn           uid=monitor \
        --monitorUserPassword     password \
        --acceptLicense

./bin/dsconfig --offline --no-prompt --batch <<END_OF_COMMAND_INPUT
# Use default values for the following global settings so that it is possible to run tools when building derived images.
set-global-configuration-prop --set "server-id:&{ds.server.id|docker}"
set-global-configuration-prop --set "group-id:&{ds.group.id|default}"
set-global-configuration-prop --set "advertised-listen-address:&{ds.advertised.listen.address|localhost}"
set-global-configuration-prop --advanced --set "trust-transaction-ids:&{platform.trust.transaction.header|false}"

delete-log-publisher --publisher-name "File-Based Error Logger"
delete-log-publisher --publisher-name "Replication Repair Logger"
delete-log-publisher --publisher-name "File-Based Access Logger"
delete-log-publisher --publisher-name "File-Based Audit Logger "
delete-log-publisher --publisher-name "File-Based HTTP Access Logger"
delete-log-publisher --publisher-name "Json File-Based Access Logger"
delete-log-publisher --publisher-name "Json File-Based HTTP Access Logger"

create-log-publisher --type console-error --publisher-name "Console Error Logger" --set enabled:true --set default-severity:error --set default-severity:warning --set default-severity:notice --set override-severity:SYNC=INFO,ERROR,WARNING,NOTICE
create-log-publisher --type external-access --publisher-name "Console LDAP Access Logger" --set enabled:true --set config-file:config/audit-handlers/ldap-access-stdout.json --set "filtering-policy:&{ds.log.filtering.policy|inclusive}"
create-log-publisher --type external-http-access --publisher-name "Console HTTP Access Logger" --set enabled:true --set config-file:config/audit-handlers/http-access-stdout.json

delete-sasl-mechanism-handler --handler-name "GSSAPI"

set-synchronization-provider-prop --provider-name "Multimaster synchronization" --set "bootstrap-replication-server:&{ds.bootstrap.replication.servers|localhost:8989}"
# TODO: Uncomment this once we support database encryption (OPENDJ-6598).
# create-replication-domain --provider-name "Multimaster synchronization" --domain-name "cn=admin data" --set "base-dn:cn=admin data"
# TODO: Uncomment this once we support optional schema replication.
# create-replication-domain --provider-name "Multimaster synchronization" --domain-name "cn=schema" --set "base-dn:cn=schema" --set "enabled:&{ds.enable.schema.replication|false}"
delete-replication-domain --provider-name "Multimaster synchronization" --domain-name "cn=schema"
END_OF_COMMAND_INPUT

./bin/ldifmodify config/config.ldif > config/config.ldif.tmp << EOF
dn: cn=Filtering Criteria,cn=Filtered Json File-Based Access Logger,cn=Loggers,cn=config
changetype: moddn
newrdn: cn=Filtering Criteria
deleteoldrdn: 0
newsuperior: cn=Console LDAP Access Logger,cn=Loggers,cn=config

dn: cn=Filtered Json File-Based Access Logger,cn=Loggers,cn=config
changetype: delete
EOF
rm config/config.ldif
mv config/config.ldif.tmp config/config.ldif

mkdir -p data secrets
mv db/schema config

# The keystore and PIN will be provided at runtime in the secrets directory.
# The SSL keys can be removed from the build time keystore, but the master-key must be kept
# because it may be needed when building derived images. For example, the import-ldif tool
# requires crypto services even if it is not encrypting data.
keytool -delete -keystore config/keystore -storepass:file config/keystore.pin -alias ca-cert
keytool -delete -keystore config/keystore -storepass:file config/keystore.pin -alias ssl-key-pair

# Remove the default passwords for the admin and monitor accounts.
removeUserPassword() {
    file=$1
    dn=$2

    ./bin/ldifmodify "${file}" > "${file}.tmp" << EOF
dn: ${dn}
changetype: modify
delete: userPassword
EOF
    rm "${file}"
    mv "${file}.tmp" "${file}"
}

removeUserPassword db/rootUser/rootUser.ldif "uid=admin"
removeUserPassword db/monitorUser/monitorUser.ldif "uid=monitor"
