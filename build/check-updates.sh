#!/usr/bin/env bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
#
# Scripts of the "Watch updates" workflow, so that they can be read and run outside of it
#
#   check-updates.sh [version...]    print the PHP versions that need a new build (separated by spaces)
#   check-updates.sh start <versions>  start "Build all" for them, unless a build is running or just failed
#   check-updates.sh cleanup [days]  delete the finished runs older than <days> days (default 7)
#
# check: for each version it asks build/config.sh (CHECK_ONLY=1)
# whether the published image still matches the fingerprint of its current inputs.
# Only manifests and registry APIs are read, nothing is built or pulled.
# Progress is written to stderr, the result to stdout. In a workflow the result is also
# added to GITHUB_OUTPUT as "versions=".
#
# Start and cleanup use the GitHub CLI (gh), with GH_TOKEN set

BASE_DIR="$(git rev-parse --show-toplevel)"
source "$BASE_DIR/build/helpers.sh"
source "$BASE_DIR/build/versions.sh"

# Seconds to wait after a failed "Build all" before starting another one
FAILED_BUILD_WAIT=10800
# Days that cleanup keeps the finished runs when no number is given
KEEP_DAYS_DEFAULT=7

################################################################################
# check: PHP versions that need a new build
################################################################################

# One probe: "<version> <os> <app> <result of config.sh>". Runs in xargs, so it is exported.
probe() {
    local app="$1" os="$2" version="$3"
    local result
    [ "$os" = "debian" ] && os=""
    [ "$version" = "-" ] && version=""
    result="$("$BASE_DIR/build/config.sh" "$os" "$app" "$version" 2>/dev/null | tail -n 1)"
    echo "${version:--} ${os:-debian} $app ${result:-error}"
}
export -f probe

# Usage: check_updates [version...]   (default: all versions)
check_updates() {
    local versions=("$@") version os app apps results stale ordered

    export CHECK_ONLY=1
    export PUBLISH_TO_GHCR="${PUBLISH_TO_GHCR:-1}"
    export BASE_DIR

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

    echo "PHP versions to build: ${ordered[*]:-none}" >&2
    echo "${ordered[*]}"
    [ -z "$GITHUB_OUTPUT" ] || echo "versions=${ordered[*]}" >> "$GITHUB_OUTPUT"
}

################################################################################
# start: run "Build all"
################################################################################

# Seconds since an ISO 8601 time like 2026-11-20T11:00:00Z (GNU date on the runners, BSD date on a Mac)
seconds_since() {
    local then
    then="$(date -d "$1" +%s 2>/dev/null || date -j -u -f '%Y-%m-%dT%H:%M:%SZ' "$1" +%s)" || return 1
    echo $(( $(date +%s) - then ))
}

# Usage: start_build <versions, separated by spaces>
start_build() {
    local versions="$1" active last age

    # Wait for the running build, it will pick up what changed so far
    active="$(gh run list --workflow build-all.yml --limit 20 --json status \
        --jq '[.[] | select(.status == "in_progress" or .status == "queued" or .status == "waiting" or .status == "pending")] | length')"
    if [ "$active" != "0" ]; then
        echo "Build all is still running ($active). Will check again later."
        return 0
    fi

    # Do not retry a failing build in a loop
    last="$(gh run list --workflow build-all.yml --limit 1 --json conclusion,createdAt \
        --jq '.[0] | select(.conclusion == "failure") | .createdAt')"
    if [ -n "$last" ]; then
        age="$(seconds_since "$last")" || age=
        if [ -n "$age" ] && [ "$age" -lt "$FAILED_BUILD_WAIT" ]; then
            echo "The last build failed ${age}s ago. Waiting before the next try."
            return 0
        fi
    fi

    gh workflow run build-all.yml --ref main -f php_versions="$versions"
    echo "Started Build all for: $versions"
}

################################################################################
# cleanup: delete old finished runs
################################################################################

# Runs started by a release are kept.
# Usage: cleanup_runs [days]   (0 deletes all finished runs)
cleanup_runs() {
    local days="${1:-$KEEP_DAYS_DEFAULT}" id

    case "$days" in
        ''|*[!0-9]*) echo "keep_days must be a whole number, got: $days" >&2; return 1 ;;
    esac

    echo "Delete finished runs older than $days days"
    gh run list --limit 1000 --json databaseId,event,status,createdAt \
        --jq ".[] | select(.status == \"completed\" and .event != \"release\" and (.createdAt | fromdateiso8601) < (now - $days * 86400)) | .databaseId" |
        while read -r id; do
            gh run delete "$id"
        done
}

################################################################################
# Run, unless the file is sourced (tests/run.sh sources it)
################################################################################
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    set -e
    case "$1" in
        start)   shift; start_build "$*" ;;
        cleanup) shift; cleanup_runs "$@" ;;
        *)       check_updates "$@" ;;
    esac
fi
