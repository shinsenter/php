#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# build/versions.sh and the version helpers of build/helpers.sh.

source "$(dirname "$0")/lib.sh"
source "$BASE_DIR/build/helpers.sh"
source "$BASE_DIR/build/versions.sh"

# Lists
check "maintained list is not empty" [ "${#MAINTAINED_PHP_VERSIONS[@]}" -gt 0 ]
check "outdated list is not empty" [ "${#OUTDATED_PHP_VERSIONS[@]}" -gt 0 ]
check_eq "ALL_PHP_VERSIONS size" \
    "$((${#MAINTAINED_PHP_VERSIONS[@]} + ${#OUTDATED_PHP_VERSIONS[@]}))" \
    "${#ALL_PHP_VERSIONS[@]}"
check_eq "duplicated versions" "" \
    "$(printf '%s\n' "${ALL_PHP_VERSIONS[@]}" | sort | uniq -d)"

for outdated in "${OUTDATED_PHP_VERSIONS[@]}"; do
    check "$outdated is outdated" is_outdated_php "$outdated"
    for maintained in "${MAINTAINED_PHP_VERSIONS[@]}"; do
        check "$outdated is older than $maintained" verlt "$outdated" "$maintained"
    done
done
for maintained in "${MAINTAINED_PHP_VERSIONS[@]}"; do
    check_not "$maintained is not outdated" is_outdated_php "$maintained"
done
check_not "unknown version is not outdated" is_outdated_php "9.9"

# Alpine images start at PHP 7.1
check_not "alpine 5.6" has_alpine_php 5.6
check_not "alpine 7.0" has_alpine_php 7.0
check "alpine 7.1" has_alpine_php 7.1
check "alpine 7.4" has_alpine_php 7.4
check "alpine 8.5" has_alpine_php 8.5
check "alpine 8.6-rc" has_alpine_php 8.6-rc

# Version compare
check "verlte 7.4 8.0" verlte 7.4 8.0
check "verlte 8.0 8.0" verlte 8.0 8.0
check_not "verlte 8.1 8.0" verlte 8.1 8.0
check "verlt 7.9 7.10" verlt 7.9 7.10
check_not "verlt 8.0 8.0" verlt 8.0 8.0
check "verlt 8.5 8.6-rc" verlt 8.5 8.6-rc
check "active 8.3" is_active_version 8.3
check_not "active 8.2" is_active_version 8.2
check_not "active 7.4" is_active_version 7.4

finish
