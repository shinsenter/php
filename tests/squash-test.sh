#!/bin/sh -e
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
LOG_DIR="$BASE_DIR/tests/logs"

if [ ! -x "$BASE_DIR/build/docker-squash/docker-squash.sh" ]; then
    echo "No squash script." 1>&2
    exit 1
fi

if [ "$1" = "clean" ] || [ "$1" = "clear" ]; then
    docker system prune -af
    docker volume prune -f
    rm -rf "$LOG_DIR/"*
    clear
    shift
fi

. $BASE_DIR/build/helpers.sh

platform="linux/${PLATFORM:-amd64}"
variant="${PHP_VARIANT:-}"
dockerfile="$BASE_DIR/src/${DOCKERFILE:-php/base-php.dockerfile}"
context=$(dirname $dockerfile)

if [ ! -f "$context/meta.dockerfile" ]; then
    cp -p "$BASE_DIR/src/php/meta.dockerfile" "$context/meta.dockerfile"
fi

for version; do
    set -xe
    $BASE_DIR/build/docker-squash/docker-squash.sh "$dockerfile" \
        --no-cache \
        --tag "docker-php-$version-${DOCKERTAG:-$variant}:squashed" \
        --platform  "$platform" \
        --build-arg S6_VERSION=$(get_github_latest_tag "just-containers/s6-overlay" 1) \
        --build-arg PHP_VERSION=$version \
        --build-arg PHP_VARIANT=$variant \
        2>&1 | tee "$BASE_DIR/tests/logs/squash-$version-${DOCKERTAG:-$variant}.txt" &
done

# example
# PLATFORM=arm64 DOCKERTAG=nginx DOCKERFILE=php/with-nginx.dockerfile PHP_VARIANT=fpm-alpine ./tests/squash-test.sh 5.6 8.4-rc
# PLATFORM=arm64 DOCKERTAG=f8p DOCKERFILE=php/with-f8p.dockerfile PHP_VARIANT=zts ./tests/squash-test.sh 8.3
# PLATFORM=arm64 DOCKERTAG=unit DOCKERFILE=php/with-unit.dockerfile PHP_VARIANT=zts ./tests/squash-test.sh 8.2
# PLATFORM=arm64 DOCKERTAG=roadrunner DOCKERFILE=php/with-roadrunner.dockerfile PHP_VARIANT=cli ./tests/squash-test.sh 8.0 8.3
# PLATFORM=arm64 DOCKERTAG=bedrock DOCKERFILE=webapps/bedrock/bedrock.dockerfile PHP_VARIANT= ./tests/squash-test.sh 8.3
