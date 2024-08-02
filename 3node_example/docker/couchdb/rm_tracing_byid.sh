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
jq 'del(.static_resources.listeners[].filter_chains[].filters[].typed_config.tracing)' resp.json > full.json
jq --arg jq_var ${rev} '._rev = $jq_var' full.json > $json_file
curl -X PUT -H "Content-Type: application/json" -d @"$json_file" "http://$username:$password@localhost:5984/$dbname/$id"
rm resp.json full.json
popd > /dev/null
