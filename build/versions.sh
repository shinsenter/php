#!/usr/bin/env bash
# PHP versions handled by the build workflows.
#
# - maintained: rebuilt whenever one of its inputs changes
#               (official PHP image, Composer, IPE, s6-overlay, servers, sources).
# - outdated:   rebuilt only when the official PHP image of that version changes.
#
# The workflows read these lists from here. The only copy is the alpine `exclude`
# in .github/workflows/template-php.yml (a matrix cannot call shell): keep it in
# sync with has_alpine_php.

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

# Alpine images exist only from PHP 7.1 (needs verlt from helpers.sh).
has_alpine_php() {
    ! verlt "$1" "7.1"
}
