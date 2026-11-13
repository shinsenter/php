#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Where the build steps find the files that were downloaded once per run
HELPER_CACHE_DIR="${HELPER_CACHE_DIR:-/tmp/helper_cache}"
WPCLI_URL="${WPCLI_URL:-https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar}"

################################################################################
# Versions
################################################################################

# True when $1 is less than or equal to $2
verlte() {
    printf '%s\n' "$1" "$2" | sort -C -V
}

# True when $1 is less than $2
verlt() {
    ! verlte "$2" "$1"
}

is_active_version() {
    verlt "8.2" "$1"
}

################################################################################
# Remote content
################################################################################

# Fetch a URL and keep the answer for the rest of the day.
# TOKEN, when set, goes in as a bearer token. Other arguments go to curl.
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

# GitHub API of a repository, with the token when there is one.
# Usage: github_api <owner/repo>/<path>
github_api() {
    TOKEN="$GITHUB_TOKEN" fetch_with_cache "https://api.github.com/repos/$1"
}

# Docker Hub API of a repository, with the credentials when there are some.
# Usage: dockerhub_api <namespace/repo>/<path>
dockerhub_api() {
    local auth=
    if [ -n "$DOCKERHUB_USERNAME" ] && [ -n "$DOCKERHUB_PASSWORD" ]; then
        auth="-u $DOCKERHUB_USERNAME:$DOCKERHUB_PASSWORD"
    fi
    fetch_with_cache "https://registry.hub.docker.com/v2/repositories/$1" "$auth"
}

# Run a jq query on JSON and print the first lines. Fails when there is no result.
# Usage: parse_json <json> [lines, default 1] [jq query, default .]
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

# Newest tag names of a GitHub repository
# Usage: get_github_latest_tag <owner/repo> [lines, default 1]
get_github_latest_tag() {
    parse_json "$(github_api "$1/tags?per_page=5&")" "${2:-1}" \
        '.[] | if type == "object" then (.name // empty) else empty end'
}

# Tag of the latest stable release (pre-releases are not included)
get_github_latest_release() {
    local json
    json="$(github_api "$1/releases/latest")" || return 1
    parse_json "$json" 1 '.tag_name // empty'
}

# Digest of one exact tag on Docker Hub (e.g. library/php 8.5-fpm).
# Do not use the "name=" search of the tags API for this: it matches substrings
# and returns whichever tag was updated last (8.5-fpm-alpine3.23, 8.5-fpm-bookworm...).
get_dockerhub_tag_digest() {
    local json
    json="$(dockerhub_api "$1/tags/$2")" || return 1
    # Old tags that are no longer updated have a null digest, the push time is stable for them
    parse_json "$json" 1 '.digest // .tag_last_pushed // empty'
}

# Same as above, but a failed lookup returns a value that changes on every run,
# so the image is rebuilt instead of being wrongly treated as up to date.
get_dockerhub_tag_digest_or_now() {
    local digest
    digest="$(get_dockerhub_tag_digest "$@")" || true
    echo "${digest:-unknown-$(date +%s)}"
}

# Nginx version number from https://nginx.org.
# "mainline" and "stable" are looked up on the download page, "os", empty and numbers pass through.
# Usage: resolve_nginx_version <mainline|stable|os|number>
resolve_nginx_version() {
    local want="$1" label page
    case "$want" in
        mainline) label=Mainline ;;
        stable)   label=Stable ;;
        *)        echo "$want"; return 0 ;;
    esac
    page="$(fetch_with_cache "https://nginx.org/en/download.html")" || return 1
    echo "$page" \
        | sed -n "s|.*<h4>$label version</h4>||p" \
        | grep -oE 'nginx-[0-9]+(\.[0-9]+)+\.tar\.gz' \
        | head -n 1 | sed 's/^nginx-//; s/\.tar\.gz$//'
}

################################################################################
# Downloads for the build steps
################################################################################
# Each cache_* function puts its files in HELPER_CACHE_DIR once per run,
# so the image builds do not download them again (and do not call the GitHub API,
# which allows 60 requests per hour without a token).
# A failed download is not fatal, except for cache_middleware_sources:
# the build step downloads the file itself.

# Download a file, fail on HTTP errors
# Usage: download_file <url> <path>
download_file() {
    curl --retry 3 --retry-delay 5 -fsSLo "$2" "$1"
}

# Download a file into the helper cache
# Usage: cache_file <url> <file name>
cache_file() {
    mkdir -p "$HELPER_CACHE_DIR"
    download_file "$1" "$HELPER_CACHE_DIR/$2"
}

# Sources of the latest brotli and curl, for src/php/common/patches/middleware-patch
cache_middleware_sources() {
    local tag version

    tag="$(get_github_latest_release "google/brotli")" || return 1
    version="${tag#v}"
    cache_file "https://github.com/google/brotli/archive/refs/tags/v$version.tar.gz" \
        "brotli-$version.tar.gz" || return 1

    tag="$(get_github_latest_release "curl/curl")" || return 1
    version="$(echo "${tag#curl-}" | tr _ .)"
    cache_file "https://curl.se/download/curl-$version.tar.xz" \
        "curl-$version.tar.xz" || return 1
}

# Nginx and ngx_brotli sources for src/php/with-nginx/nginx-build
cache_nginx_source() {
    local version
    version="$(resolve_nginx_version "${NGINX_VERSION:-mainline}")"
    case "$version" in ""|os) return 0 ;; esac
    cache_file "https://nginx.org/download/nginx-$version.tar.gz" "nginx-$version.tar.gz" \
        || echo "Cannot cache Nginx $version" >&2
    # ngx_brotli has no release: the latest commit is used, and it is not part of the fingerprint
    cache_file "https://github.com/google/ngx_brotli/archive/HEAD.tar.gz" "ngx_brotli.tar.gz" \
        || echo "Cannot cache ngx_brotli" >&2
}

# s6-overlay archives for src/php/common/os-s6-overlay.dockerfile.
# The file name is s6-<version>-<name on GitHub>.
cache_s6_sources() {
    local version="${S6_VERSION:-}" name
    case "$version" in ""|latest) version="$(get_github_latest_tag "just-containers/s6-overlay" 1)" ;; esac
    [ -n "$version" ] || return 0
    for name in s6-overlay-noarch syslogd-overlay-noarch \
        s6-overlay-x86_64 s6-overlay-aarch64 s6-overlay-arm s6-overlay-i686 s6-overlay-s390x; do
        cache_file "https://github.com/just-containers/s6-overlay/releases/download/$version/$name.tar.xz" \
            "s6-$version-$name.tar.xz" || echo "Cannot cache $name $version" >&2
    done
}

# WP-CLI for src/webapps/wordpress/wordpress.dockerfile.
# The file is checked against the checksum that WP-CLI publishes.
cache_wpcli_source() {
    local file="$HELPER_CACHE_DIR/wp-cli.phar" expected actual
    expected="$(fetch_with_cache "$WPCLI_URL.sha512" | awk '{print $1}')"
    if cache_file "$WPCLI_URL" wp-cli.phar && [ -n "$expected" ]; then
        actual="$(shasum -a 512 "$file" | awk '{print $1}')"
        [ "$actual" = "$expected" ] && return 0
        echo "Checksum mismatch for wp-cli.phar, not cached" >&2
    fi
    rm -f "$file"
    echo "Cannot cache wp-cli.phar" >&2
}

################################################################################
# Published images
################################################################################

# Manifest of a published image as JSON (empty if there is none).
# It reads the manifest only, no layer is pulled.
image_manifest() {
    docker buildx imagetools inspect --raw "$1" 2>/dev/null
}

# Fingerprint stored in the index manifest of a published image (empty if none)
get_image_fingerprint() {
    image_manifest "$1" \
        | jq -r '.annotations["org.shinsenter.build.fingerprint"] // empty' 2>/dev/null
}

# Compressed size in bytes of an image manifest: config plus layers (reads JSON on stdin)
manifest_size() {
    jq -r '[.config.size // 0] + [.layers[]?.size] | add // empty' 2>/dev/null
}

# Compressed size of one platform of a published image (empty if it is not published)
# Usage: get_image_size <image:tag> [arch, default amd64]
get_image_size() {
    local image="$1" arch="${2:-amd64}" digest
    digest="$(image_manifest "$image" \
        | jq -r --arg arch "$arch" '[.manifests[]? | select(.platform.os == "linux" and .platform.architecture == $arch)][0].digest // empty' 2>/dev/null)"
    [ -n "$digest" ] || return 0
    image_manifest "${image%:*}@$digest" | manifest_size
}

################################################################################
# Build context
################################################################################

# Folder with the security backports of a PHP version (empty when there is none)
find_backport_dir() {
    [ -n "$1" ] && [ -d "$BASE_DIR/src/php-backports/php$1" ] && echo "$BASE_DIR/src/php-backports/php$1"
    return 0
}

# Files that config.sh adds to the build context.
# The build jobs of each platform run this again, because they start from a clean checkout.
# Usage: prepare_build_context <dockerfile> <context> <php-version>
prepare_build_context() {
    local dockerfile="$1" context="$2" php_version="$3" backports

    [ ! -d "$context/rootfs" ] && mkdir -p "$context/rootfs"
    # Mounted by common/os-common.dockerfile, it is empty unless the workflow fills it
    mkdir -p "$context/helper_cache"
    [ ! -e "$context/meta.dockerfile" ] && \
        cp -pf "$BASE_DIR/src/php/meta.dockerfile" "$context/meta.dockerfile"

    # Security backports for end-of-life PHP versions (see src/php/common/php-backports.dockerfile).
    # The folder is always there, it is empty for the versions without backports.
    if [ "$dockerfile" = "$BASE_DIR/src/php/base-php.dockerfile" ] && [ "$CHECK_ONLY" != "1" ]; then
        backports="$(find_backport_dir "$php_version")"
        rm -rf "$context/php-backports"
        mkdir -p "$context/php-backports"
        [ -n "$backports" ] && cp -pR "$backports" "$context/php-backports/"
    fi
    return 0
}

# Print a variable for the shell, or add it to the GitHub Actions environment.
# In a workflow it also goes to BUILD_ENV_FILE, for the jobs that run after this one (see template-common.yml).
# Usage: github_env <name> <value...>
github_env() {
    local name="$1"; shift
    if [ -t 1 ] || [ -z "$GITHUB_ENV" ]; then
        echo "$name='$*'"
        return 0
    fi
    echo "$name=$*"
    echo "$name=$*" >> "$GITHUB_ENV"
    [ -z "$BUILD_ENV_FILE" ] || echo "$name=$*" >> "$BUILD_ENV_FILE"
    return 0
}

################################################################################
# Hashing
################################################################################

# Hash each file listed on stdin, in a stable order
hash_files() {
    sort -dbfi | xargs -r shasum 2>/dev/null
}

# Hash of the files that go into one image (first 10 characters).
# - The Dockerfile fragments in sub folders count: INCLUDE pulls them into the build.
# - The top level Dockerfiles do not: the image hashes its own Dockerfile apart, the others are other images.
# - The folder of another server (with-*) does not count, only the folder named like the Dockerfile.
# - Markdown, hidden files and the backports (hashed apart) do not count.
# Usage: get_context_hash <context-folder> <dockerfile>
get_context_hash() {
    local context="$1" own
    own="$(basename "${2%.dockerfile}")"
    find "$context" -type f ! -name '.*' ! -name '*.md' \
        ! -path '*/php-backports/*' \
        ! \( -path "$context/*.dockerfile" ! -path "$context/*/*" ! -name 'meta.dockerfile' \) \
        ! \( -path "$context/with-*/*" ! -path "$context/$own/*" \) \
        | hash_files | shasum | head -c10
}

# One hash line per file of each folder or file given (hidden files and Markdown are left out)
# Usage: path_hash [path...]
path_hash() {
    if [ "$#" -eq 0 ]; then
        echo -n "" | shasum
        return
    fi

    for target; do
        if [ -n "$target" ]; then
            if [ -d "$target" ]; then
                find "$target" -type f ! -name '.*' ! -name '*.md' | hash_files
            elif [ -f "$target" ]; then
                shasum "$target" 2>/dev/null
            else
                echo -n "$@" | shasum 2>/dev/null
            fi
        fi
    done
}

# Examples
# get_github_latest_tag     "just-containers/s6-overlay"
# get_github_latest_release "google/brotli"
# get_dockerhub_tag_digest  "library/php" "8.5-fpm"
# path_hash ./.github/workflows/template-*
