#!/bin/bash
dbname="users"
username="imo"
password="123456"
configDir="/tmp"
port=5984
echo "listening on port $port"
if [ $# -gt 0 ]
then
	configDir=$1
fi	
echo "converting all Envoy configs to json files"
pushd $configDir > /dev/null
for file in $(find . -type f -name "*.yaml"); do
    name=$(basename "$file")
    id="${name%.yaml}"
    json_file="${file%.yaml}.json"
    echo "Processing $name jsonfile: $json_file"
    #python3 -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=4)' < "$file" > "${file%.yaml}.json"
    python3 -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=4)' < "$file" > tmp.json

    echo "verifying in resp.json"
    response=$(curl -s -X GET "http://$username:$password@localhost:5984/$dbname/$id")
    #echo $response | jq > ${id}_resp.json
    rev=$(echo $response | jq -r '._rev')
    echo "rev: $rev"
    jq --arg jq_var ${rev} '._rev = $jq_var' tmp.json > $json_file
    echo "curl -X PUT -H Content-Type: application/json -d @$json_file http://$username:$password@localhost:5984/$dbname/$id"
    curl -X PUT -H "Content-Type: application/json" -d @"$json_file" "http://$username:$password@localhost:5984/$dbname/$id"
done
rm tmp.json
popd > /dev/null
