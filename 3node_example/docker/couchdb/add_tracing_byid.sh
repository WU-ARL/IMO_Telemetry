#!/bin/bash
dbname="users"
username="imo"
password="123456"
configDir="/tmp"
port=5984

if [ $# -lt 1 ]
then
    echo "Usage: $0 <node id>"
    exit
fi
pushd $configDir > /dev/null
id=$1
json_file=${id}.json

echo "verifying in resp.json"
response=$(curl -s -X GET "http://$username:$password@localhost:5984/$dbname/$id")
rev=$(echo $response | jq -r '._rev')
echo $response | jq 'del(._id, ._rev)' > resp.json

echo "rev: $rev for $id"
#first remove tracing if it is already turned on
jq 'del(.static_resources.listeners[].filter_chains[].filters[].typed_config.request_id_extension)' resp.json > no_request_id.json
jq 'del(.static_resources.listeners[].filter_chains[].filters[].typed_config.tracing)' no_request_id.json > no_tracing.json
#if is not on then add it
jq --arg srv_name ${id} '(.static_resources.listeners[] | select(."name"!="listen_otlp_stats") | .filter_chains[].filters[].typed_config | select(."@type"=="type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager")) += {"tracing": {"provider":{"name": "envoy.tracers.opentelemetry", "typed_config": {"@type":"type.googleapis.com/envoy.config.trace.v3.OpenTelemetryConfig", "grpc_service": {"envoy_grpc": {"cluster_name": "jaeger_stats"},"timeout": "1s"},"service_name": $srv_name}}}}' no_tracing.json > resp.json
jq --arg srv_name ${id} '(.static_resources.listeners[] | select(."name"!="listen_otlp_stats") | .filter_chains[].filters[].typed_config | select(."@type"=="type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager")) += {"request_id_extension": {"typed_config": {"@type":"type.googleapis.com/envoy.extensions.request_id.uuid.v3.UuidRequestIdConfig"}}}' resp.json > full.json
jq --arg jq_var ${rev} '._rev = $jq_var' full.json > $json_file
curl -X PUT -H "Content-Type: application/json" -d @"$json_file" "http://$username:$password@localhost:5984/$dbname/$id"
rm resp.json full.json no_tracing.json no_request_id.json
popd > /dev/null



