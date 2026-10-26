#!/usr/bin/env bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
#
# Prints the PHP versions that need a new build (separated by spaces).
#
# For each version it asks build/config.sh (CHECK_ONLY=1) whether the published
# image still matches the fingerprint of its current inputs. Only manifests and
# registry APIs are read, nothing is built or pulled.
#
# Usage: ./build/check-updates.sh [version...]   (default: all versions)
#        Progress is written to stderr, the result to stdout.

set -e

BASE_DIR="$(git rev-parse --show-toplevel)"
source "$BASE_DIR/build/helpers.sh"
source "$BASE_DIR/build/versions.sh"

export CHECK_ONLY=1
export PUBLISH_TO_GHCR="${PUBLISH_TO_GHCR:-1}"
export BASE_DIR

versions=("$@")
[ "${#versions[@]}" -eq 0 ] && versions=("${ALL_PHP_VERSIONS[@]}")

jobs_file="$(mktemp)"
trap 'rm -f "$jobs_file"' EXIT

# Images that do not depend on a PHP version (rebuilt together with the first version)
{
    echo "base-s6 alpine -"
    echo "base-os debian -"
    echo "base-os ubuntu -"
    echo "base-os alpine -"
} >"$jobs_file"

for version in "${versions[@]}"; do
    for os in debian alpine; do
        if [ "$os" = "alpine" ] && ! has_alpine_php "$version"; then
            continue
        fi

        apps=(cli fpm zts)
        if ! is_outdated_php "$version"; then
            apps+=(with-apache with-nginx with-f8p with-roadrunner)
        fi

        for app in "${apps[@]}"; do
            echo "$app $os $version" >>"$jobs_file"
        done
    done
done

probe() {
    local app="$1" os="$2" version="$3"
    local result
    [ "$os" = "debian" ] && os=""
    [ "$version" = "-" ] && version=""
    result="$("$BASE_DIR/build/config.sh" "$os" "$app" "$version" 2>/dev/null | tail -n 1)"
    echo "${version:--} ${os:-debian} $app ${result:-error}"
}
export -f probe

results="$(xargs -P 8 -L 1 bash -c 'probe $0 $1 $2' <"$jobs_file" | sort)"

echo "$results" | awk '{ printf "%-8s %-8s %-16s %s\n", $1, $2, $3, $4 }' >&2

# Versions with at least one stale or unreadable image
stale="$(echo "$results" | awk '$4 != "up-to-date" && $1 != "-" { print $1 }' | sort -u)"

# Version-less images are stale: build them with the newest maintained version
if echo "$results" | awk '$4 != "up-to-date" && $1 == "-" { found=1 } END { exit !found }'; then
    stale="$(printf '%s\n%s\n' "$stale" "${versions[0]}" | sort -u)"
fi

# Keep the order of the version list
ordered=()
for version in "${versions[@]}"; do
    if echo "$stale" | grep -qx -- "$version"; then
        ordered+=("$version")
    fi
done

echo "${ordered[*]}"
