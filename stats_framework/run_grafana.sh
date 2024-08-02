#!/bin/bash

PWD=$(pwd)
nohup docker run --rm --name grafana -p 0.0.0.0:3000:3000 -v ${PWD}/../../../grafana_data.passwd:/var/lib/grafana grafana/grafana:latest > /dev/null &

