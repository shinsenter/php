#!/bin/sh
BASE_DIR="$(git rev-parse --show-toplevel)"
TEST_DIR="$BASE_DIR/tests"

export DOCKER_BUILDKIT=1
export S6_VERSION="$(cat $BASE_DIR/S6_VERSION.txt)"
export PHP_VERSION="${1:-8.1}"
export BUILD_PLATFORM="${2:-linux/arm/v6}"

clear
$BASE_DIR/.git-config/hooks/pre-commit

echo
echo "🤖 Starting building S6 ${S6_VERSION} and \
php:${PHP_VERSION} images for platform ${BUILD_PLATFORM}..."

echo && date \
&& docker-compose -f $TEST_DIR/docker-compose.base.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.cli.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.fpm.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.server.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.webapps.yml build \
&& echo "Finished."