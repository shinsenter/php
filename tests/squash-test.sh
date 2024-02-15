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

variant="${PHP_VARIANT:-fpm}"
dockerfile="${DOCKERFILE:-php/base-php.dockerfile}"

for version; do
    set -xe
    $BASE_DIR/build/docker-squash/docker-squash.sh \
        "$BASE_DIR/src/$dockerfile" \
        -t docker-php-$version-$variant:squashed --no-cache \
        --build-arg S6_VERSION=$(get_github_latest_tag "just-containers/s6-overlay" 1) \
        --build-arg PHP_VERSION=$version \
        --build-arg PHP_VARIANT=$variant \
        --build-arg PRESQUASH_SCRIPTS=cleanup \
        2>&1 | tee "$BASE_DIR/tests/logs/squash-$version-$variant.txt" &
done
