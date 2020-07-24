#!/usr/bin/env bash

# Prerequisites:
#
# 1. Docker
# 2. gradle

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

cd udf
gradle wrapper
./gradlew clean build
cd ..
docker-compose up -d
