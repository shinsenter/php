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

# Function to get remote json
get_remote_json () {
    echo "Fetching $@" 1>&2
    if [ "$TOKEN" != "" ]; then
        curl --retry 3 --retry-delay 5 -ksL \
            --header "Authorization: Bearer $TOKEN" \
            --request GET --url "$@" | tr -d '[:cntrl:]'
    else
        curl --retry 3 --retry-delay 5 -ksL "$@" | tr -d '[:cntrl:]'
    fi
}

# Function to get metadata from GitHub
get_github_json () {
    TOKEN="$GITHUB_TOKEN" get_remote_json "https://api.github.com/repos/$1/tags?per_page=10&$2"
}

# Function to get metadata from Docker Hub
get_dockerhub_json () {
    TOKEN="$DOCKERHUB_TOKEN" get_remote_json "https://registry.hub.docker.com/v2/repositories/$1/tags?&page_size=10&status=active&sort=last_updated&$2"
}

# For GitHub
get_github_latest_tag () { get_github_json "$1" | jq -r '.[].name // empty' | head -n ${2:-1}; }
get_github_latest_sha () { get_github_json "$1" | jq -r '.[].commit.sha // empty' | head -n ${2:-1}; }

# For Docker Hub
get_dockerhub_latest_tag () { get_dockerhub_json "$1" "name=${3:-}" | jq -r '.results|.[].name // empty' | head -n ${2:-1}; }
get_dockerhub_latest_sha () { get_dockerhub_json "$1" "name=${3:-}" | jq -r '.results|.[].digest // empty' | head -n ${2:-1}; }

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
    if [ "$1" == "" ]; then
        echo -n "" | shasum
        return
    fi

    local target="$1"
    if [ -d $target ]; then
        find "$target" -type f \
        | grep -v '\.(DS_Store|git)' \
        | sort -zn | xargs -r shasum 2>/dev/null
    elif [ -f $target ]; then
        shasum $target 2>/dev/null
    else
        echo -n "$@" | shasum 2>/dev/null
    fi
}

################################################################################
# Testing and debug
################################################################################

# get_github_latest_tag    "just-containers/s6-overlay"
# get_github_latest_tag    "nginx/unit"
# get_github_latest_tag    "roadrunner-server/roadrunner"
# get_dockerhub_latest_tag "library/php"
# get_dockerhub_latest_tag "dunglas/frankenphp" 1 "1-php8.3-alpine"
# get_dockerhub_latest_sha "library/alpine"
# get_dockerhub_latest_sha "library/ubuntu"
# get_dockerhub_latest_sha "library/debian"
