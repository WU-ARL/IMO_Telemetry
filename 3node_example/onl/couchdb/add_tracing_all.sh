#!/bin/bash

ENVOYS=( envoyLocal envoyIngress envoyLB1 envoyLB2 )

for ENVOY in "${ENVOYS[@]}"
do
	./add_tracing_byid.sh $ENVOY
done
