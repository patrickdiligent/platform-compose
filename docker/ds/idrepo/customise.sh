#!/usr/bin/env bash
# Sample utility to make a lot of bulk users.
# Usage:  make-users.sh number-users [uid-start-number]
cd /opt/opendj

echo "INITIALISING"

/opt/opendj/docker-entrypoint.sh initialize-only

#### Perform here any customisation before the server is started
echo "PRE START CUSTOMIZE"
####

preExec() {
    echo
    echo "Server configured with:"
    echo "    Group ID                        : $DS_GROUP_ID"
    echo "    Server ID                       : $DS_SERVER_ID"
    echo "    Advertised listen address       : $DS_ADVERTISED_LISTEN_ADDRESS"
    echo "    Bootstrap replication server(s) : $DS_BOOTSTRAP_REPLICATION_SERVERS"
    echo
}

preExec
start-ds #--nodetach

#### Perform here anny customisations that requires the server is started, such as changing account passwords
echo "POST START CUSTOMIZE"
####

sleep infinity
