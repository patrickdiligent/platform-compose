#!/usr/bin/env bash
#
# Copyright 2020 ForgeRock AS. All Rights Reserved
#

set -o errexit
set -o pipefail
set -x

mv $AM_HOME/config/services/realm/root/iplanetamplatformservice/1.0/globalconfig/default/com-sun-identity-servers/http___localhost_8080_am.json \
    $AM_HOME/config/services/realm/root/iplanetamplatformservice/1.0/globalconfig/default/com-sun-identity-servers/http___am_80_am.json

cd $AM_HOME/config
oldHostname="http://localhost:8080"
newHostname="http://am:80"
find . -name '*.json' -type f -exec sed -i "s+$oldHostname+$newHostname+g" {} \;

mv /opt/templates/boot.json $AM_HOME/config

"$FORGEROCK_HOME"/placeholder/amupgrade/amupgrade -i "$AM_HOME"/config/services -o "$AM_HOME"/config/services --fileBasedMode --prettyArrays "$FORGEROCK_HOME"/placeholder/amupgrade/rules/placeholders/7.0.0-placeholders.groovy
"$FORGEROCK_HOME"/placeholder/amupgrade/amupgrade -i "$AM_HOME"/config/services -o "$AM_HOME"/config/services --fileBasedMode "$FORGEROCK_HOME"/serverconfig-modification.groovy

rawIdRepoValue="LDAPv3ForOpenDS"
placeholderedIdRepoValue="\&{am.stores.user.type}"
find . -name 'opendj.json' -type f -exec sed -i "s+$rawIdRepoValue+$placeholderedIdRepoValue+g" {} \;

mv /opt/templates/serverconfig.xml $AM_HOME/config/services/realm/root/iplanetamplatformservice/1.0/globalconfig/default/com-sun-identity-servers/
