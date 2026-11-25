#!/bin/bash
#
# Usage:
#   ./build.sh              # build v5.0.0
#   ./build.sh <version>    # build jumpserver/*:<version>-ce (the tag must exist)
set -e

version="${1:-v5.0.0}"

docker build \
    --platform linux/amd64 \
    --build-arg version="${version}-ce" \
    -t "jumpserver/jms_all:${version}" \
    .
