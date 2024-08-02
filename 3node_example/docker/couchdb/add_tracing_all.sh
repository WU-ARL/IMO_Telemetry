#!/bin/bash

ENVOYS=( node1 node2 node3 )

for ENVOY in "${ENVOYS[@]}"
do
	./add_tracing_byid.sh $ENVOY
done
