#!/bin/bash
ID=011
ENVOY_DIR=/usr/local/bin/
ADMINP=9003 #9${ID}

PWD=$(pwd)
DOCKER=$1
CONTROLLER=$2
TYPE=static
if [ $CONTROLLER -gt 0 ]
then
	TYPE=basedyn
fi
ENVOY_CFG=(envoy_${TYPE}*.yaml)
if [ $# -gt 2 ]
then
	ENVOY_CFG=envoy_${TYPE}_$2.yaml
fi

if [ $DOCKER -eq 0 ]
then
	echo "envoy -c $PWD/${ENVOY_CFG}  >& /tmp/envoy.log"
	envoy -c $PWD/${ENVOY_CFG}  >& /tmp/envoy.log
	#echo "envoy -c $PWD/${ENVOY_CFG} --concurrency 1  >& /tmp/envoy.log"
	#envoy -c $PWD/${ENVOY_CFG} --concurrency 1  >& /tmp/envoy.log
else
	#docker pull envoyproxy/envoy:v1.29-latest
	#docker run --rm -p 0.0.0.0:18080:18080/tcp -p 0.0.0.0:${ADMINP}:${ADMINP} -v "$PWD/${ENVOY_CFG}":/etc/envoy/envoy.yaml -v "$PWD/cert.pem":/etc/envoy/cert.pem -v "$PWD/key.pem":/etc/envoy/key.pem --name envoy -t envoyproxy/envoy >& /tmp/docker.envoy.log
	docker pull bitnami/envoy:latest
	docker run --rm --network host -p 192.168.1.1:18443:18443/tcp -p 192.168.1.1:18080:18080/tcp -p 0.0.0.0:${ADMINP}:${ADMINP} -v "$PWD/controller.crt":/etc/envoy/controller.crt -v "$PWD/${ENVOY_CFG}":/opt/bitnami/envoy/conf/envoy.yaml -v "$PWD/cert.pem":/etc/envoy/cert.pem -v "$PWD/key.pem":/etc/envoy/key.pem --name envoy -t bitnami/envoy >& /tmp/docker.envoy.log
fi
