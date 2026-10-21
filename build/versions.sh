#!/usr/bin/env bash
# PHP versions handled by the build workflows.
#
# - maintained: rebuilt whenever one of its inputs changes
#               (official PHP image, Composer, IPE, s6-overlay, servers, sources).
# - outdated:   rebuilt only when the official PHP image of that version changes.
#
# Keep the literal lists in .github/workflows/template-php.yml in sync with this file.

MAINTAINED_PHP_VERSIONS=(8.6-rc 8.5 8.4 8.3 8.2)
OUTDATED_PHP_VERSIONS=(8.1 8.0 7.4 7.3 7.2 7.1 7.0 5.6)
ALL_PHP_VERSIONS=("${MAINTAINED_PHP_VERSIONS[@]}" "${OUTDATED_PHP_VERSIONS[@]}")

is_outdated_php() {
    local item
    for item in "${OUTDATED_PHP_VERSIONS[@]}"; do
        [ "$item" = "$1" ] && return 0
    done
    return 1
}
