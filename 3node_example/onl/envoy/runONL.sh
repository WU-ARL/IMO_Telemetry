#! /bin/bash


if [ $# -lt 2 ]
then
  echo "Usage: $0 <username> <docker 0/1> <controller 0/1> [<envoy cfg token>]"
  exit 0
fi
echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
DOCKER=$2
CONTROLLER=$3
if [ $# -gt 3 ]
then
	ENVOY_CFG=$4
fi
echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology
ENVOY_DIR=$(pwd)

HOSTS=( h3x1 h5x1 h1x1 )
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${ENVOY_DIR}/run_${HST}; ./run-envoy-docker-ONL.sh $DOCKER $CONTROLLER $ENVOY_CFG"
	ssh -x $HST_MACHINE "cd ${ENVOY_DIR}/run_${HST}; ./run-envoy-docker-ONL.sh $DOCKER $CONTROLLER $ENVOY_CFG" &
done

