#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# build/config.sh paths that finish before any network call: Alpine images
# that do not exist for old PHP versions are skipped.

source "$(dirname "$0")/lib.sh"

config_value() {
    BUILD_TAG_PREFIX=local- "$BASE_DIR/build/config.sh" "$@" 2>/dev/null
}

for version in 5.6 7.0; do
    output="$(config_value alpine cli "$version")"
    check_eq "alpine cli $version: SKIP_BUILD" "SKIP_BUILD='1'" \
        "$(grep '^SKIP_BUILD=' <<<"$output")"
    check_eq "alpine cli $version: BUILD_DOCKERFILE" "BUILD_DOCKERFILE=''" \
        "$(grep '^BUILD_DOCKERFILE=' <<<"$output")"
    check_eq "alpine cli $version: BUILD_TAG" \
        "BUILD_TAG='shinsenter/php:local-$version-cli-alpine'" \
        "$(grep '^BUILD_TAG=' <<<"$output")"
done

finish
