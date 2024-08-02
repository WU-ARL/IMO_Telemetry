#!/bin/bash


test_with_ctl() {
    echo ""
    echo "Test with controller"

    echo "copy tracing configurations to current dir"
    cp ${COUCHDB_CONFIGS_DIR}/${ENVOY_CFGS}/*yaml ${COUCHDB_CONFIGS_DIR}/

    # Run CouchDB
    echo "Start CounchDB"
    echo "ssh -x $STATS_HOST_MACHINE cd ${PWD} ; ./runCouchDB.sh ${COUCHDB_CONFIGS_DIR} >& /tmp/couchdb.log" 
    ssh -x $STATS_HOST_MACHINE "cd ${PWD} ; ./runCouchDB.sh ${COUCHDB_CONFIGS_DIR} >& /tmp/couchdb.log" &
    echo "sleep 10"
    sleep 10

    # Run Controller
    echo "Start Envoy Controller"
    echo "ssh -x $STATS_HOST_MACHINE cd ${PWD} ; ./runController.sh ${CONTROLLER_DIR} ${STATS_HOST_IP} >& /tmp/controller.log"
    ssh -x $STATS_HOST_MACHINE "cd ${PWD} ; ./runController.sh ${CONTROLLER_DIR} ${STATS_HOST_IP} >& /tmp/controller.log" &
    echo "sleep 10"
    sleep 10

    echo "Start Envoy"
    pushd ${ENVOY_DIR} >& /dev/null
    ./runONL.sh $USERNAME $DOCKER $CONTROLLER $ENVOY_CFG >& /dev/null
    #./runONL.sh $USERNAME $DOCKER $CONTROLLER $ENVOY_CFG 
    popd >& /dev/null
    echo "sleep 20"
    sleep 20

    if [ $NO_STATS -eq 0 ]
    then
    	echo "Start stats"
    	ssh -x $STATS_HOST_MACHINE "cd ${SCRIPTS} ; ./run_all_stats.sh ${STATS_SINK} >& /tmp/stats.log" &
    	echo "sleep 5"
    	sleep 5
    fi
    
    echo "Start nginx for producer1"
    ssh -x $NGINX_HOST1_MACHINE "cd ${NGINX_DIR} ; ./run-docker.sh >& /tmp/nginx.docker.log" &
    sleep 5

    # This appears to be the place we need to sleep for things to settle.
    # After a reboot it can take over 10 seconds for the docker process to come up and
    # get configured. Later re-runs seem to take more like 5-6 seconds. 
    # so, we just have to make sure we give them time.
    echo "sleep 20 to give stats and envoys time to get going"
    sleep 20
    
    #time=$(date +%H:%M:%S)


}
test_no_ctl() {
    echo ""
    echo "Test Envoy with no controller"


    echo "Start Envoy"
    pushd ${ENVOY_DIR} >& /dev/null
    echo "./runONL.sh $USERNAME $DOCKER >& /dev/null"
    ./runONL.sh $USERNAME $DOCKER $CONTROLLER >& /dev/null
    #./runONL.sh $USERNAME $DOCKER $CONTROLLER  
    popd >& /dev/null
    echo "sleep 20"
    sleep 20

    if [ $NO_STATS -eq 0 ]
    then
    	echo "Start stats"
    	echo "ssh -x $STATS_HOST_MACHINE cd ${SCRIPTS} ; ./run_all_stats.sh ${STATS_SINK} >& /tmp/stats.log"
    	ssh -x $STATS_HOST_MACHINE "cd ${SCRIPTS} ; ./run_all_stats.sh ${STATS_SINK} >& /tmp/stats.log" &
    	echo "sleep 5"
    	sleep 5
    fi

    echo "Start nginx for producer1"
    ssh -x $NGINX_HOST1_MACHINE "cd ${NGINX_DIR} ; ./run-docker.sh >& /tmp/nginx.docker.log" &
    sleep 5
    # This appears to be the place we need to sleep for things to settle.
    # After a reboot it can take over 10 seconds for the docker process to come up and
    # get configured. Later re-runs seem to take more like 5-6 seconds. 
    # so, we just have to make sure we give them time.
    echo "sleep 10 to give stats and envoys time to get going"
    sleep 10

    #time=$(date +%H:%M:%S)


}

cleanup() {
echo "Cleanup all"
./cleanup.sh $USERNAME $(pwd)/${PARAM_FILE}
#ssh -x $STATS_HOST_MACHINE "killall prometheus; killall jaeger-all-in-one; killall otelcol-jp"
echo "Done with cleanup"
}
#####################################################

clear
if [ $# -lt 2 ]
then
  echo "Usage: $0 <username> <test param file relative to this dir> [<stats|no_stats> <docker|no_docker> <controller|no_controller> default yes for each "
  exit 0
fi
echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
ENVOY_CFGS=default
NO_STATS=0
DOCKER=1
CONTROLLER=1
PARAM_FILE=$2
COUCHDB_CONFIGS_DIR=$(pwd)/../couchdb
source $(pwd)/${PARAM_FILE}
if [ $# -gt 2 ]
then
	for ARG in "$@"
	do
		echo "arg $ARG"
		if [ $ARG == "stats" ]
		then
			echo "stats will be run"
			NO_STATS=0
		elif [ $ARG == "no_stats" ]
		then
			echo "no_stats will be run"
			NO_STATS=1
		elif [ $ARG == "docker" ]
		then
			echo "envoy run in docker"
			DOCKER=1
		elif [ $ARG == "no_docker" ]
		then
			echo "envoy not run in docker"
			DOCKER=0
		elif [ $ARG == "controller" ]
		then
			echo "envoy controller"
			CONTROLLER=1
		elif [ $ARG == "no_controller" ]
		then
			echo "static envoy no controller"
			CONTROLLER=0
		fi
	done
fi
echo "LOGNAME: $LOGNAME "
source /users/$LOGNAME/.topology
SLEEP_TIME=10
STATS_SINK=1
if [ $NO_STATS -gt 0 ]
then
	STATS_SINK=0
else
	eval STATS_HOST_MACHINE=\$$STATS_HOST
fi

PWD=$(pwd)
echo "PWD: $PWD"
ENVOY_DIR=$(pwd)/../envoy

CONTROLLER_DIR=$(pwd)/../controller
SCRIPTS=$(pwd)

NGINX_DIR=$(pwd)/../nginx_http

NGINX_HOST1="h1x1"
eval NGINX_HOST1_MACHINE=\$$NGINX_HOST1
    
rm -rf ${NGINX_DIR}/N_* ${NGINX_DIR}/Y_* 
cleanup
if [ $CONTROLLER -gt 0 ]
then
	test_with_ctl
else
	test_no_ctl
fi

echo "all configured."
echo "hit return to end"
read response
sleep 5
cleanup

echo "All Done"

