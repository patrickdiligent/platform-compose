
if [ ! -z "$WAIT_FOR_AM" ]
then
    curl --silent $WAIT_FOR_AM/isAlive.jsp | grep "Server is ALIVE:" 
    STATUS=$?
    while [ "$STATUS" != "0" ]; do
        echo "Waiting for AM...."
        sleep 10
        curl --silent $WAIT_FOR_AM/isAlive.jsp | grep "Server is ALIVE:"
        STATUS=$?
        if [ ! -f /home/shared/ready ]; then
            STATUS=1
        fi
    done
fi

${INSTALL_DIR}/bin/start.sh ${IG_INSTANCE_DIR}
