#! /bin/bash
ORIG_DIR=$(pwd)
pushd .

#Run prometheus
echo "docker run --rm -d -p 9090:9090 --name prometheus -v ${ORIG_DIR}/prometheus_otel.yml:/etc/prometheus/prometheus.yml  prom/prometheus >& /tmp/prometheus.log "
docker run --rm -d -p 9090:9090 --name prometheus -v ${ORIG_DIR}/prometheus_otel.yml:/etc/prometheus/prometheus.yml  prom/prometheus >& /tmp/prometheus.log 

echo "docker run --rm --name jaeger -p 16686:16686 -p 14250:14250 -p 4317:4317 jaegertracing/all-in-one:latest >& /tmp/jaeger.log &"
docker run --rm --name jaeger -p 16686:16686 -p 14250:14250 -p 4317:4317 jaegertracing/all-in-one:latest >& /tmp/jaeger.log &
popd

${ORIG_DIR}/run_otel_collector.sh 
