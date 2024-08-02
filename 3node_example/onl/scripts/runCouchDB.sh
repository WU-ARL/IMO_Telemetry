#!/bin/bash
dbname="users"
username="imo"
password="123456"
configDir="$PWD/../couchdb"
port=5984


if [ $# -gt 0 ]
then
	configDir=$1
fi
echo "couchdb file dir ${configDir}"
echo "listening on port $port"
#cd $PWD/../../../envoyControlPlane/CouchDB
#rm -rf "$PWD/db/*"
docker pull couchdb
docker run --rm -d -p 0.0.0.0:$port:5984 -e "COUCHDB_USER=$username" -e "COUCHDB_PASSWORD=$password" --name db -t couchdb 
if curl -s -X GET "http://$username:$password@localhost:5984/_all_dbs" | grep -q "\"$dbname\""; then
  echo "Database $dbname exists, deleting it"
  curl -X DELETE "http://$username:$password@localhost:5984/$dbname"
fi
# Wait for CouchDB to be up
echo "Waiting for CouchDB to start..."
while ! curl -s http://localhost:5984/ > /dev/null; do
  sleep 1
done
echo "CouchDB started."

if curl -s -X GET "http://$username:$password@localhost:5984/_all_dbs" | grep -q "\"$dbname\""; then
  echo "Database $dbname exists, deleting it"
  curl -X DELETE "http://$username:$password@localhost:5984/$dbname"
fi

echo "Building $dbname DB"
sleep 5
echo "curl -X PUT http://$username:$password@localhost:5984/$dbname"
curl -X PUT "http://$username:$password@localhost:5984/$dbname"
echo "Manually add _users database"
curl -X PUT "http://$username:$password@localhost:5984/_users"

rm *.json
echo "converting all Envoy configs to json files"
pushd $configDir > /dev/null
for file in ./*.yaml; do
    name=$(basename "$file")
    echo "Processing $name"
    python3 -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=4)' < "$file" > "${file%.yaml}.json"
done
popd > /dev/null

echo "Adding configs to DB"
pushd $configDir > /dev/null
for file in ./*.json; do
    name=$(basename "$file")
    echo "Processing $name"
    id="${name%.json}"
    curl -X PUT -H "Content-Type: application/json" -d @"$file" "http://$username:$password@localhost:5984/$dbname/$id"
done
popd > /dev/null

echo "adding secrets..."
curl -X PUT -d '{"client":"client_pass","server":"server_pass","intermediate":"intermediate_pass"}' "http://$username:$password@localhost:5984/$dbname/secrets"
