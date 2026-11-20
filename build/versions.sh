#!/usr/bin/env bash
# PHP versions handled by the build workflows
#
# - maintained: rebuilt whenever one of its inputs changes
#               (official PHP image, Composer, IPE, s6-overlay, servers, sources).
# - outdated:   rebuilt only when the official PHP image of that version changes.
#
# The workflows read these lists from here.
# The only copy is the alpine `exclude` in .github/workflows/template-php.yml
# (a matrix cannot call shell): keep it in sync with has_alpine_php.

MAINTAINED_PHP_VERSIONS=(8.6 8.5 8.4 8.3 8.2)
OUTDATED_PHP_VERSIONS=(8.1 8.0 7.4 7.3 7.2 7.1 7.0 5.6)
ALL_PHP_VERSIONS=("${MAINTAINED_PHP_VERSIONS[@]}" "${OUTDATED_PHP_VERSIONS[@]}")

is_outdated_php() {
    local item
    for item in "${OUTDATED_PHP_VERSIONS[@]}"; do
        [ "$item" = "$1" ] && return 0
    done
    return 1
}

# Alpine images exist only from PHP 7.1 (needs verlt from helpers.sh)
has_alpine_php() {
    ! verlt "$1" "7.1"
}

# PHP versions to build, one per line, in build order. Fails on an unknown version.
# Outdated versions go first: they build slower (old toolchains, PHP rebuilt from source for 7.3 to 8.1),
# so they do not wait for a free runner at the end.
# Usage: select_php_versions [requested versions, separated by spaces or commas, empty = all]
select_php_versions() {
    local requested="${1//,/ }" item version found
    local selected=()

    if [ -z "${requested// /}" ]; then
        selected=("${ALL_PHP_VERSIONS[@]}")
    else
        for item in $requested; do
            found=
            for version in "${ALL_PHP_VERSIONS[@]}"; do
                if [ "$version" = "$item" ] || [ "${version%-rc}" = "$item" ]; then
                    selected+=("$version")
                    found=1
                fi
            done
            if [ -z "$found" ]; then
                echo "Unknown PHP version: $item" >&2
                return 1
            fi
        done
    fi

    for version in "${OUTDATED_PHP_VERSIONS[@]}" "${MAINTAINED_PHP_VERSIONS[@]}"; do
        for item in "${selected[@]}"; do
            if [ "$item" = "$version" ]; then
                echo "$version"
                break
            fi
        done
    done
}
