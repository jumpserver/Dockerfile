#!/bin/bash
#
# Run the all-in-one image locally
#   ./demo_run.sh            # v5.0.0
#   ./demo_run.sh v5.0.1     # specific version
set -e

version="${1:-v5.0.0}"

docker volume create jsdata >/dev/null 2>&1 || true
docker volume create pgdata >/dev/null 2>&1 || true

docker run --name jms_all \
     -v jsdata:/opt/data \
     -v pgdata:/var/lib/postgresql \
     -p 8085:80 \
     "jumpserver/jms_all:${version}"
