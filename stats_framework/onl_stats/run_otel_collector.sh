#! /bin/bash
ORIG_DIR=$(pwd)
TOP_DIR=/etc/ONL/bin 
OTEL_BIN_DIR=${TOP_DIR} 
CFG_FILE=${ORIG_DIR}/otel-collector-config.yaml
if [ $# -lt 1 ]
then
	echo "Usage: $0 [full path of config file default: ./otel-collector-config.yaml]"
else
	CFG_FILE=$1
fi

#run the custom build of the otelcol to enable the statsd receiver
#echo "${OTEL_BIN_DIR}/otelcol-jp --config ${CFG_FILE} >& /tmp/otel-collector.log &"
#${OTEL_BIN_DIR}/otelcol-jp --config ${CFG_FILE} >& /tmp/otel-collector.log &
echo "docker run  -v ${CFG_FILE}:/etc/otelcol/config.yaml -p 0.0.0.0:8889:8889 -p 0.0.0.0:8888:8888 -p 0.0.0.0:4317:4317 -p 0.0.0.0:4318:4318 -p 0.0.0.0:4319:4319 --name otlp --network=host otel/opentelemetry-collector:latest >& /tmp/otel-collector.log &"
docker run  -v ${CFG_FILE}:/etc/otelcol/config.yaml -p 0.0.0.0:8889:8889 -p 0.0.0.0:8888:8888 -p 0.0.0.0:4317:4317 -p 0.0.0.0:4318:4318 -p 0.0.0.0:4319:4319 --name otlp --network=host otel/opentelemetry-collector:latest >& /tmp/otel-collector.log &
