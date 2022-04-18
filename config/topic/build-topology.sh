#!/usr/bin/env bash

set -u -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

docker run -t -i \
      -v ${DIR}/config:/config \
      --network="julie-playground_default"\
      purbon/kafka-topology-builder:latest \
      /bin/bash -c 'julie-ops-cli.sh --brokers broker:29092 --clientConfig /config/topology-builder.properties  --topology /config/schemaless-topic.yml'
