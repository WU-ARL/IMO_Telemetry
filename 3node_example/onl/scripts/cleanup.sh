#! /bin/bash


if [ $# -lt 2 ]
then
	echo "Usage: $0 <username> <stats host (e.g. h1x1)>"
	echo "      kills all docker processes and stats components on stats host"
  exit 0
fi
#echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
#echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology
SCRIPTS=$(pwd)
STATS_HOST=$2
eval STATS_HOST_MACHINE=\$$STATS_HOST

echo "ssh -x $STATS_HOST_MACHINE cd ${SCRIPTS}; ./stopAllDockerOnHost.sh; killall prometheus; killall jaeger-all-in-one; killall otelcol-jp; "
ssh -x $STATS_HOST_MACHINE "cd ${SCRIPTS}; ./stopAllDockerOnHost.sh; killall prometheus; killall jaeger-all-in-one; killall otelcol-jp; "

