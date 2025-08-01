#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

################################################################################
# TTY helper methods
################################################################################

echo_error()    { echo $@ 1>&2; }
echo_warning()  { echo $@ 1>&2; }
echo_info()     { echo $@; }
echo_debug()    { echo $@; }

################################################################################
# Helper methods
################################################################################

# Function to compare if $1 is less than or equal to $2
verlte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}

# Function to compare if $1 is less than $2
verlt() {
    ! verlte "$2" "$1"
}

# Function to get current timestamp
timestamp() {
    date +%s
}

# Function to fetch and cache remote content
fetch_with_cache() {
    local url="${1%-}"
    local cache_dir="/tmp/helper_cache"
    local today=$(date +"%Y%m%d")
    local hash=$(echo -n "$url" | md5sum | awk '{print $1}')
    local cache_file="${cache_dir}/${today}_${hash}.cache"

    mkdir -p "$cache_dir"
    shift

    if [[ -f "$cache_file" ]]; then
        echo "Cache found for $url" 1>&2
        cat "$cache_file"
    else
        echo "Fetching $url" 1>&2
        content=$(
            if [ "$TOKEN" != "" ]; then
                curl --retry 3 --retry-delay 5 -ksSLRJ "$@" \
                    --header "Authorization: Bearer $TOKEN" \
                    "$url"
            else
                curl --retry 3 --retry-delay 5 -ksSLRJ "$@" "$url"
            fi
        )

        if [[ $? -eq 0 && -n "$content" ]]; then
            echo "$content" | tr -d '[:cntrl:]' >"$cache_file"
            cat "$cache_file"
        else
            echo "Failed to fetch content from $url" >&2
            return 1
        fi
    fi
}

# Function to get metadata from GitHub
get_github_json () {
    TOKEN="$GITHUB_TOKEN" fetch_with_cache "https://api.github.com/repos/$1/tags?per_page=10&$2"
}

# Function to get metadata from Docker Hub
get_dockerhub_json () {
    local options=
    if [ -n "$DOCKERHUB_USERNAME" ] && [ -n "$DOCKERHUB_PASSWORD" ]; then
        options="-u $DOCKERHUB_USERNAME:$DOCKERHUB_PASSWORD"
    fi
    fetch_with_cache "https://registry.hub.docker.com/v2/repositories/$1/tags?&page_size=10&status=active&sort=last_updated&$2" "$options"
}

# Function to parse JSON and return
parse_json() {
    local json="$1"
    local limit="${2:-1}"
    local jq_query="${3:-.}"
    local result="$(echo "$json" | jq -r "$jq_query" | head -n $limit)"

    if [ -z "$result" ]; then
        return 1
    fi

    echo "$result"
}

# For GitHub
get_github_latest_tag () { parse_json "$(get_github_json "$1")" "${2:-1}" '.[] | if type == "object" then (.name // empty) else empty end'; }
get_github_latest_sha () { parse_json "$(get_github_json "$1")" "${2:-1}" '.[] | if type == "object" then (.commit.sha // .node_id // empty) else empty end'; }

# For Docker Hub
get_dockerhub_latest_tag () { parse_json "$(get_dockerhub_json "$1" "name=${3:-latest}")" "${2:-1}" '.results[] | if type == "object" then (.name // empty) else empty end'; }
get_dockerhub_latest_sha () { parse_json "$(get_dockerhub_json "$1" "name=${3:-latest}")" "${2:-1}" '.results[] | if type == "object" then (.digest // .tag_last_pushed // .id // empty) else . end'; }

# Function to set environment variables
github_env() {
    local name="$1"; shift
    if [ -t 1 ]; then
        echo "$name=$@"
    else
        echo "$name=$@"
        echo "$name=$@" >> $GITHUB_ENV
    fi
}

################################################################################
# Hashing functions
################################################################################

path_hash() {
    if [ $# -eq 0 ]; then
        echo -n "" | shasum
        return
    fi

    for target; do
        if [ -n "$target" ]; then
            if [ -d "$target" ]; then
                find "$target" -type f ! -name '.*' ! -name '*.md' \
                | sort -dbfi | xargs -r shasum 2>/dev/null
            elif [ -f "$target" ]; then
                shasum "$target" 2>/dev/null
            else
                echo -n "$@" | shasum 2>/dev/null
            fi
        fi
    done
}

################################################################################
# Testing and debug
################################################################################

# get_github_latest_tag    "just-containers/s6-overlay"
# get_github_latest_sha    "just-containers/s6-overlay"
# get_github_latest_tag    "nginx/unit"
# get_github_latest_sha    "nginx/unit"
# get_github_latest_tag    "roadrunner-server/roadrunner"
# get_github_latest_sha    "roadrunner-server/roadrunner"
# get_dockerhub_latest_tag "library/php"
# get_dockerhub_latest_tag "dunglas/frankenphp" 1 "1-php8.4-alpine"
# get_dockerhub_latest_sha "library/alpine"
# get_dockerhub_latest_sha "library/ubuntu"
# get_dockerhub_latest_sha "library/debian"
# path_hash ./.github/workflows/template-*
