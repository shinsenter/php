#!/bin/sh
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
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

# Function to compare two version strings
verlte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}

# Function to compare two version strings
verlt() {
    ! verlte "$2" "$1"
}

# Function to get current timestamp
timestamp() {
    date +%s
}

# Function to fetch and cache remote content
fetch_with_cache() {
    local url="$@"
    local cache_dir="/tmp/helper_cache"
    local today=$(date +"%Y%m%d")
    local hash=$(echo -n "$url" | md5sum | awk '{print $1}')
    local cache_file="${cache_dir}/${today}_${hash}.cache"

    mkdir -p "$cache_dir"

    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
    else
        echo "Fetching $@" 1>&2
        content=$(
            if [ "$TOKEN" != "" ]; then
                curl --retry 3 --retry-delay 5 -ksL \
                    --header "Authorization: Bearer $TOKEN" \
                    --request GET --url "$url"
            else
                curl --retry 3 --retry-delay 5 -ksL "$url"
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
    TOKEN="$DOCKERHUB_TOKEN" fetch_with_cache "https://registry.hub.docker.com/v2/repositories/$1/tags?&page_size=10&status=active&sort=last_updated&$2"
}

# For GitHub
get_github_latest_tag () { get_github_json "$1" | jq -r '.[].name // empty' | head -n ${2:-1}; }
get_github_latest_sha () { get_github_json "$1" | jq -r '.[].commit.sha // empty' | head -n ${2:-1}; }

# For Docker Hub
get_dockerhub_latest_tag () { get_dockerhub_json "$1" "name=${3:-latest}" | jq -r '.results|.[].name // empty' | head -n ${2:-1}; }
get_dockerhub_latest_sha () { get_dockerhub_json "$1" "name=${3:-latest}" | jq -r '.results|.[].digest // empty' | head -n ${2:-1}; }

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
        if [ ! -z "$target" ]; then
            if [ -d "$target" ]; then
                find "$target" -type f -not -name '.*' \
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
# get_github_latest_tag    "nginx/unit"
# get_github_latest_tag    "roadrunner-server/roadrunner"
# get_dockerhub_latest_tag "library/php"
# get_dockerhub_latest_tag "dunglas/frankenphp" 1 "1-php8.4-alpine"
# get_dockerhub_latest_sha "library/alpine"
# get_dockerhub_latest_sha "library/ubuntu"
# get_dockerhub_latest_sha "library/debian"
# path_hash ./.github/workflows/template-*
