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

if [ ! -x "$BASE_DIR/tests/action-test.sh" ]; then
    echo "No test script." 1>&2
    exit 1
fi

if [ "$1" = "clean" ] || [ "$1" = "clear" ]; then
    docker system prune -af
    docker volume prune -f
    rm -rf /.cache/act
    clear
    shift
fi

set -xe
for version; do
    $BASE_DIR/tests/action-test.sh \
        --job    "${ACTION_JOB:-php-images-main}" \
        --matrix "php_version:$version" \
        | tee "$BASE_DIR/tests/logs/build-$os-$app-$version.txt" &
done
