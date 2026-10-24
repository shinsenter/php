#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

################################################################################
# TTY helper methods
################################################################################

echo_error()    { echo $@ >&2; }
echo_warning()  { echo $@ >&2; }
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

is_active_version() {
    verlt "8.2" "$1"
}

# Function to get current timestamp
timestamp() {
    date +%s
}

# Function to fetch and cache remote content
fetch_with_cache() {
    local url="$1"

    url="${url%-}"
    url="${url%&}"
    url="${url%\/}"

    local cache_dir="/tmp/helper_cache"
    local today="$(date +"%Y%m%d")"
    local hash="$(echo -n "$url" | md5sum | awk '{print $1}')"
    local cache_file="${cache_dir}/${today}_${hash}.cache"

    mkdir -p "$cache_dir"
    shift

    if [ -f "$cache_file" ]; then
        echo "Cache found for $url" >&2
        cat "$cache_file"
    else
        echo "Fetching $url" >&2
        content="$(
            if [ "$TOKEN" != "" ]; then
                curl --retry 3 --retry-delay 5 -ksSLRJ $@ \
                    --header "Authorization: Bearer $TOKEN" \
                    "$url"
            else
                curl --retry 3 --retry-delay 5 -ksSLRJ $@ "$url"
            fi
        )"

        if [ "$?" -eq 0 ] && [ -n "$content" ]; then
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
    local name="$1"
    local query="$2"
    local limit="${3:-5}"
    TOKEN="$GITHUB_TOKEN" fetch_with_cache "https://api.github.com/repos/$name/tags?per_page=$limit&$query"
}

# Function to get metadata from Docker Hub
get_dockerhub_json () {
    local name="$1"
    local query="$2"
    local limit="${3:-5}"
    local options=
    if [ -n "$DOCKERHUB_USERNAME" ] && [ -n "$DOCKERHUB_PASSWORD" ]; then
        options="-u $DOCKERHUB_USERNAME:$DOCKERHUB_PASSWORD"
    fi
    fetch_with_cache "https://registry.hub.docker.com/v2/repositories/$name/tags?&page_size=$limit&status=active&sort=last_updated&$query" "$options"
}

# Function to parse JSON and return
parse_json() {
    local json="$1"
    local limit="${2:-1}"
    local jq_query="${3:-.}"
    local result="$(echo "$json" | jq -r "$jq_query" | head -n "$limit")"

    if [ -z "$result" ]; then
        return 1
    fi

    echo "$result"
}

# For GitHub
get_github_latest_tag () { parse_json "$(get_github_json "$1")" "${2:-1}" '.[] | if type == "object" then (.name // empty) else empty end'; }
# Tag of the latest stable release (pre-releases are not included)
get_github_latest_release () {
    local json
    json="$(TOKEN="$GITHUB_TOKEN" fetch_with_cache "https://api.github.com/repos/$1/releases/latest")" || return 1
    parse_json "$json" 1 '.tag_name // empty'
}
get_github_latest_sha () { parse_json "$(get_github_json "$1")" "${2:-1}" '.[] | if type == "object" then (.commit.sha // .node_id // empty) else empty end'; }

# For Docker Hub
get_dockerhub_latest_tag () { parse_json "$(get_dockerhub_json "$1" "name=${3:-latest}")" "${2:-1}" '.results[] | if type == "object" then (.name // empty) else empty end'; }
get_dockerhub_latest_sha () { parse_json "$(get_dockerhub_json "$1" "name=${3:-latest}")" "${2:-1}" '.results[] | if type == "object" then (.digest // .tag_last_pushed // .id // empty) else . end'; }

# Digest of one exact tag on Docker Hub (e.g. library/php 8.5-fpm).
# Do not use the "name=" search of the tags API for this: it matches substrings
# and returns whichever tag was updated last (8.5-fpm-alpine3.23, 8.5-fpm-bookworm...).
get_dockerhub_tag_digest () {
    local name="$1"
    local tag="$2"
    local options=
    if [ -n "$DOCKERHUB_USERNAME" ] && [ -n "$DOCKERHUB_PASSWORD" ]; then
        options="-u $DOCKERHUB_USERNAME:$DOCKERHUB_PASSWORD"
    fi
    local json
    json="$(fetch_with_cache "https://registry.hub.docker.com/v2/repositories/$name/tags/$tag" "$options")" || return 1
    parse_json "$json" 1 '.digest // empty'
}

# Same as above, but a failed lookup returns a value that changes on every run,
# so the image is rebuilt instead of being wrongly treated as up to date.
get_dockerhub_tag_digest_or_now () {
    local digest
    digest="$(get_dockerhub_tag_digest "$@")" || true
    echo "${digest:-unknown-$(date +%s)}"
}

# Download a file, fail on HTTP errors
download_file () {
    curl --retry 3 --retry-delay 5 -fsSLo "$2" "$1"
}

# Sources of the latest brotli and curl, for src/php/common/patches/middleware-patch.
# Downloaded once per run into the helper cache, so the image builds do not
# call the GitHub API (60 requests per hour without a token).
cache_middleware_sources () {
    local dir="/tmp/helper_cache" tag version
    mkdir -p "$dir"

    tag="$(get_github_latest_release "google/brotli")" || return 1
    version="${tag#v}"
    download_file "https://github.com/google/brotli/archive/refs/tags/v$version.tar.gz" \
        "$dir/brotli-$version.tar.gz" || return 1

    tag="$(get_github_latest_release "curl/curl")" || return 1
    version="$(echo "${tag#curl-}" | tr _ .)"
    download_file "https://curl.se/download/curl-$version.tar.xz" \
        "$dir/curl-$version.tar.xz" || return 1
}

# Fingerprint stored in the index manifest of a published image (empty if none).
# Reads the manifest only, no layer is pulled.
get_image_fingerprint () {
    docker buildx imagetools inspect --raw "$1" 2>/dev/null \
        | jq -r '.annotations["org.shinsenter.build.fingerprint"] // empty' 2>/dev/null
}

# Folder with the security backports of a PHP version (empty when there is none)
find_backport_dir() {
    [ -n "$1" ] && [ -d "$BASE_DIR/src/php-backports/php$1" ] && echo "$BASE_DIR/src/php-backports/php$1"
    return 0
}

# Files that config.sh adds to the build context. The build jobs of each
# platform run this again, because they start from a clean checkout.
# Usage: prepare_build_context <dockerfile> <context> <php-version>
prepare_build_context() {
    local dockerfile="$1" context="$2" php_version="$3" backports

    [ ! -d "$context/rootfs" ] && mkdir -p "$context/rootfs"
    # Mounted by common/os-common.dockerfile, it is empty unless the workflow fills it
    mkdir -p "$context/helper_cache"
    [ ! -e "$context/meta.dockerfile" ] && \
        cp -pf "$BASE_DIR/src/php/meta.dockerfile" "$context/meta.dockerfile"

    # Security backports for end-of-life PHP versions
    # (see src/php/common/php-backports.dockerfile). The folder is always there,
    # it is empty for the versions without backports.
    if [ "$dockerfile" = "$BASE_DIR/src/php/base-php.dockerfile" ] && [ "$CHECK_ONLY" != "1" ]; then
        backports="$(find_backport_dir "$php_version")"
        rm -rf "$context/php-backports"
        mkdir -p "$context/php-backports"
        [ -n "$backports" ] && cp -pR "$backports" "$context/php-backports/"
    fi
    return 0
}

# Function to set environment variables
github_env() {
    local name="$1"; shift
    if [ -t 1 ] || [ -z "$GITHUB_ENV" ]; then
        echo "$name='$@'"
    else
        echo "$name=$@"
        echo "$name=$@" >> $GITHUB_ENV
        # Copy for the jobs that run after this one (see template-common.yml)
        if [ -n "$BUILD_ENV_FILE" ]; then
            echo "$name=$@" >> "$BUILD_ENV_FILE"
        fi
    fi
}

################################################################################
# Hashing functions
################################################################################

path_hash() {
    if [ "$#" -eq 0 ]; then
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
# get_github_latest_tag    "roadrunner-server/roadrunner"
# get_github_latest_sha    "roadrunner-server/roadrunner"
# get_dockerhub_latest_tag "library/php"
# get_dockerhub_latest_tag "dunglas/frankenphp" 1 "1-php8.4-alpine"
# get_dockerhub_latest_sha "library/alpine"
# get_dockerhub_latest_sha "library/ubuntu"
# get_dockerhub_latest_sha "library/debian"
# path_hash ./.github/workflows/template-*
