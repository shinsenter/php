#!/bin/sh
export PHP_VERSION=${1:-8.1}
export BUILD_PLATFORM=${2:-linux/arm/v7}
export DOCKER_BUILDKIT=1

BASE_DIR="$(git rev-parse --show-toplevel)/tests"

clear \
&& bash $BASE_DIR/../.git-config/hooks/pre-commit \
&& docker-compose -f $BASE_DIR/docker-compose.base.yml build \
&& docker-compose -f $BASE_DIR/docker-compose.cli.yml build \
&& docker-compose -f $BASE_DIR/docker-compose.fpm.yml build \
&& docker-compose -f $BASE_DIR/docker-compose.server.yml build \
&& docker-compose -f $BASE_DIR/docker-compose.webapps.yml build \
&& echo "Finished."