#!/bin/bash

# Start all the other dockers
docker load -i ./controller/envoy_controller.tar
docker compose up --build


