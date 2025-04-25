#!/usr/bin/env bash

export IMAGE_NAME_TAG=$1
docker-compose -f docker-compose.yaml up --detach
echo "success"