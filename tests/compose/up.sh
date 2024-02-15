#!/bin/sh -e
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
SRC_DIR="$BASE_DIR/src"
TEST_DIR="$BASE_DIR/tests"
LOGS_DIR="$TEST_DIR/logs"
. $BASE_DIR/build/helpers.sh

if [ ! -x "$(command -v docker)" ]; then
    echo "docker is not installed. See https://docs.docker.com/get-docker/" 1>&2
    exit 1
fi

if [ ! -x "$(command -v act)" ]; then
    echo "act is not installed. See https://github.com/nektos/act" 1>&2
    exit 1
fi

if [ "$1" = "clear" ]; then
    docker system prune -af
fi

if [ "$1" = "clear" ] || [ "$1" = "clean" ]; then
    shift
    docker volume prune -f
    rm -rf $TEST_DIR/compose/data/*/
fi

################################################################################

export APP_UID="$(id -u)"
export APP_GID="$(id -g)"
export S6_VERSION="$(get_github_latest_tag "just-containers/s6-overlay" 1)"
export PHP_VERSION="${PHP_VERSION:-8.3}"
export BUILD_PLATFORM="${BUILD_PLATFORM:-linux/arm64/v8}"
export SUFFIX="${SUFFIX:-}"
export DEBUG="${DEBUG:-false}"

################################################################################

### Build
docker compose -f $TEST_DIR/compose/docker-compose.server.yml build

CODE="$?"
[ "$CODE" != "0" ] && echo "Build failed." && exit $CODE

################################################################################

### Run tests
exec docker compose -f $TEST_DIR/compose/docker-compose.webapps.yml up --build --force-recreate "$@"
