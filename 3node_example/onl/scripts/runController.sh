#!/bin/bash

if [ $# -lt 1 ]
then
    echo "Usage: $0 <Controller directory> [db host ip]"
    echo "Example: $0 /users2/jdd/IMO/envoystatsdexperiment/envoyControlPlane/Controller_Secure/"
    exit 0
else
    CONTROLLER_DIR=$1
    echo "CONTROLLER_DIR: ${CONTROLLER_DIR}"
    DB_HST_IP="192.168.5.1"
    if [ $# -gt 1 ]
    then
	    DB_HST_IP=$2
    fi
    echo "DB_HST_IP=$DB_HST_IP"
fi

cd ${CONTROLLER_DIR}
docker load -i ./envoy_controller.tar
docker run -p 18000:18000 -p 19000:19000 -v "$(pwd)/controller.crt":/controller/controller.crt -v "$(pwd)/controller.key":/controller/controller.key envoy_controller -dbHost=${DB_HST_IP} -updateTime=10s -dbPort=5984 -dbPassword="123456" -dbUserName="imo" -dbName="users"
#docker load -i ${CONTROLLER_DIR}/envoy_controller.tar
#docker run -p 18000:18000 -p 19000:19000 -v "${CONTROLLER_DIR}/controller.crt":/controller/controller.crt -v "${CONTROLLER_DIR}/controller.key":/controller/controller.key envoy_controller -dbHost=192.168.9.1 -updateTime=10s -dbPort=5984 -dbPassword="123456" -dbUserName="ONL" -dbName="users"
