#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
SQUASH_CMD="$BASE_DIR/build/docker-squash/docker-squash.sh"

set -e
source "$BASE_DIR/build/helpers.sh"

################################################################################
# Helpers
################################################################################
set_platforms() {
    case "$1" in
        ubuntu)        echo "linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x" ;;
        debian|alpine) echo "linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x" ;;
        *)             echo "linux/386,linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x" ;;
    esac
}

################################################################################
# Application rules
################################################################################
APP_RULES="
# https://roots.io/bedrock/docs/installation
bedrock:min=8.0 base=wordpress

# https://book.cakephp.org/4/en/installation.html
cakephp4:min=7.4 latest=8.3 server=apache

# https://book.cakephp.org/5/en/installation.html
cakephp5:min=8.1 server=apache

# https://codeigniter.com/user_guide/installation/index.html
codeigniter4:min=7.4 server=apache

# https://coolify.io/docs/installation
coolify:min=8.2 base=laravel

# https://www.drupal.org/docs/getting-started/system-requirements/php-requirements
drupal:min=8.0 server=apache

# https://docs.espocrm.com/administration/installation
espocrm:min=8.1 server=apache

# https://docs.flarum.org/install
flarum:min=7.3 server=nginx

# https://docs.flightphp.com
flightphp:min=7.4 server=nginx

# https://learn.getgrav.org/17/basics/installation
grav:min=7.3 server=apache

# https://hyperf.wiki/3.1/#/en/quick-start/install
hyperf:min=7.2 latest=8.3 server=nginx platform=linux/amd64,linux/arm/v7,linux/arm64/v8

# https://hypervel.org/docs/deployment
hypervel:min=8.2 base=laravel platform=linux/amd64,linux/arm/v7,linux/arm64/v8

# https://docs.invoiceshelf.com/install/manual.html
invoiceshelf:min=8.1 base=laravel

# https://getkirby.com/docs/cookbook/setup/composer
kirby:min=7.4 server=apache

# https://docs.laminas.dev/tutorials/getting-started/skeleton-application
laminas:min=7.3 latest=8.3 server=nginx

# https://laravel.com/docs/master/installation
laravel:server=nginx

# https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements
magento:min=7.4 latest=8.3 server=nginx

# https://docs.mautic.org/en/5.x/getting_started/how_to_install_mautic.html#installing-with-composer
mautic:min=7.4 latest=8.3 server=apache

# https://docs.phpmyadmin.net/en/latest/setup.html
phpmyadmin:server=nginx

# https://www.slimframework.com/docs/v4/start/installation.html
slim:server=apache

# https://spiral.dev/docs/start-installation/current/en
spiral:min=8.1 server=roadrunner variant=cli platform=linux/amd64,linux/arm64

# https://statamic.dev/installing
statamic:min=7.2 base=laravel

# https://symfony.com/doc/current/setup.html
symfony:server=apache

# https://github.com/sulu/skeleton
sulu:base=symfony

# https://wordpress.org/documentation/category/installation
wordpress:allow_rc=1 server=apache

# https://www.yiiframework.com/doc/guide/2.0/en/start-installation
yii:server=apache

## ------------------------------------------------------ ##
## inactive frameworks (kept for reference, commented out)
## ------------------------------------------------------ ##

## https://docs.craterapp.com/installation.html
# crater:min=7.4 latest=8.1 base=laravel server=apache

## https://fuelphp.com/docs/installation/instructions.html
# fuelphp:latest=8.0 server=apache

## https://phpixie.com/quickstart.html
# phpixie:latest=7.4 server=apache
"

apply_app_rules() {
    app="$1"
    rules=$(printf '%s\n' "$APP_RULES" | awk -F: -v a="$app" '$1==a {sub($1":",""); print}')
    for rule in $rules; do
        key="${rule%%=*}"
        val="${rule#*=}"
        case $key in
            min)      verlt "$PHP_VERSION" "$val" && SKIP_BUILD=1 ;;
            latest)   LATEST_PHP="$val" ;;
            base)     BUILD_FROM_IMAGE="$DEFAULT_REPO/$val"; USE_SERVER="" PREFER_SERVER="" ;;
            server)   USE_SERVER="$val" ;;
            variant)  PHP_VARIANT="$val$SUFFIX" ;;
            platform) BUILD_PLATFORM="$val" ;;
            allow_rc) ALLOW_RC=1 ;;
        esac
    done

    # Override the default server variant
    case "${PREFER_SERVER:-$USE_SERVER}" in
        httpd|apache*)
            PREFER_SERVER="apache"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-apache"
            ;;
        ngx|nginx)
            PREFER_SERVER="nginx"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
            ;;
        unit|nginx-unit)
            PREFER_SERVER="unit"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/unit-php"
            ;;
        f8p|frankenphp)
            PREFER_SERVER="frankenphp"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/frankenphp"
            ;;
        rr|roadrunner)
            PREFER_SERVER="roadrunner"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/roadrunner"
            ;;
        *) PREFER_SERVER="" ;;
    esac

    # Exception for hyperf, hypervel, spiral
    case "$app" in
        hyperf|hypervel)
            if verlte "8.3" "$PHP_VERSION"; then
                PREFER_SERVER=""
                BUILD_PLATFORM="linux/amd64,linux/arm64/v8"
            fi
            ;;
        spiral)
            PREFER_SERVER=""
            ;;
    esac
}

################################################################################
# Parse arguments
################################################################################
if [ "$#" -eq 0 ]; then
    echo "Usage: ${0##*/} <os> <app_name> <php_version> [server]" >&2
    exit 1
fi
OS="$1"; APP="$2"; PHP_VERSION="$3"; PREFER_SERVER="$4"

################################################################################
# Build environment variables
################################################################################
LATEST_PHP="8.4"
LATEST_S6=

PHP_VARIANT="${PHP_VARIANT:-}"
S6_VERSION="${S6_VERSION:-latest}"
S6_PATH="${S6_PATH:-}"
OS_BASE="${OS_BASE:-debian}"
OS_VERSION="${OS_VERSION:-latest}"
IPE_VERSION="${IPE_VERSION:-latest}"
COMPOSER_VERSION="${COMPOSER_VERSION:-latest}"

BASE_REPO="php"
DEFAULT_REPO="shinsenter"
DEFAULT_BUILD_NAME="$DEFAULT_REPO/php"
DEFAULT_README="$BASE_DIR/README.md"
MIRROR_REPO="${MIRROR_REPO:-}"

BUILD_NAME="$DEFAULT_BUILD_NAME"
BUILD_DATE="$(date +%Y-%m-%dT%T%z)"
BUILD_REVISION="$(git rev-parse HEAD)"
BUILD_FROM_IMAGE="$DEFAULT_BUILD_NAME"
BUILD_SOURCE_IMAGE=
BUILD_CONTEXT=
BUILD_DOCKERFILE=
BUILD_DOCKERFILE_SQUASHED=
BUILD_README=
BUILD_DESC=
BUILD_TAG=
BUILD_TAGS=
BUILD_TAG_PREFIX="${BUILD_TAG_PREFIX:-}"
BUILD_TMP_NAME=
BUILD_CACHE_KEY=
BUILD_CACHE_PATH="/tmp/.buildx-cache"
BUILD_PLATFORM="$(set_platforms default)"

SKIP_BUILD="${SKIP_BUILD:-0}"
SKIP_SQUASH="${SKIP_SQUASH:-0}"
USE_BUILD_CACHE="${USE_BUILD_CACHE:-1}"
ALLOW_RC=0
UPDATE_README=0

PREFIX="${APP#app-}"
SUFFIX=
USE_SERVER=

if [ -n "$OS" ] && [ "$OS" != "debian" ]; then
    SUFFIX="-$OS"
    OS_BASE="$OS"
fi

[ "$PREFER_SERVER" = "default" ] && PREFER_SERVER=""
[ "$DEBUG" = "1" ] && SKIP_BUILD=1

################################################################################
# Initialize build variables
################################################################################
case "$APP" in
    base-os)
        PHP_VERSION=
        IPE_VERSION=
        COMPOSER_VERSION=
        BUILD_NAME="$DEFAULT_REPO/$OS_BASE-s6"
        BUILD_DOCKERFILE="$BASE_DIR/src/php/base-os.dockerfile"
        BUILD_PLATFORM="$(set_platforms "$OS_BASE")"
        ;;
    base-s6)
        if [ "$OS_BASE" = "alpine" ]; then
            SKIP_SQUASH=1
            S6_PATH=/s6
            PHP_VERSION=
            IPE_VERSION=
            COMPOSER_VERSION=
            BUILD_NAME="$DEFAULT_REPO/s6-overlay"
            BUILD_DOCKERFILE="$BASE_DIR/src/php/base-s6.dockerfile"
            BUILD_PLATFORM="$(set_platforms alpine)"
        else
            SKIP_BUILD=1
        fi
        ;;
    with-apache)
        PREFIX="fpm-apache"
        BUILD_NAME="$DEFAULT_REPO/phpfpm-apache"
        BUILD_DOCKERFILE="$BASE_DIR/src/php/with-apache.dockerfile"
        PHP_VARIANT="fpm$SUFFIX"
        ALLOW_RC=1
        ;;
    with-nginx)
        PREFIX="fpm-nginx"
        BUILD_NAME="$DEFAULT_REPO/phpfpm-nginx"
        BUILD_DOCKERFILE="$BASE_DIR/src/php/with-nginx.dockerfile"
        PHP_VARIANT="fpm$SUFFIX"
        ALLOW_RC=1
        ;;
    with-unit)
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        unit_version="$(get_github_latest_tag nginx/unit)"
        PREFIX="unit"
        BUILD_NAME="$DEFAULT_REPO/unit-php"
        BUILD_DOCKERFILE="$BASE_DIR/src/php/with-unit.dockerfile"
        BUILD_SOURCE_IMAGE="https://codeload.github.com/nginx/unit/tar.gz/refs/tags/$unit_version"
        BUILD_CACHE_KEY="(unit@$(echo "$unit_version" | head -c19))"
        PHP_VARIANT="zts$SUFFIX"
        ALLOW_RC=1
        ;;
    with-f8p)
        verlt "$PHP_VERSION" "8.2" && SKIP_BUILD=1
        PREFIX="frankenphp"
        BUILD_NAME="$DEFAULT_REPO/frankenphp"
        BUILD_SOURCE_IMAGE="dunglas/frankenphp:1-php$PHP_VERSION$SUFFIX"
        BUILD_DOCKERFILE="$BASE_DIR/src/php/with-f8p.dockerfile"
        BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v7,linux/arm64/v8"
        BUILD_CACHE_KEY="(frankenphp@$(get_dockerhub_latest_sha "dunglas/frankenphp" 1 "1-php$PHP_VERSION$SUFFIX" | head -c19))"
        PHP_VARIANT="zts$SUFFIX"
        ;;
    with-roadrunner)
        verlt "$PHP_VERSION" "8.0" && SKIP_BUILD=1
        PREFIX="roadrunner"
        BUILD_NAME="$DEFAULT_REPO/roadrunner"
        BUILD_DOCKERFILE="$BASE_DIR/src/php/with-roadrunner.dockerfile"
        PHP_VARIANT="cli$SUFFIX"
        BUILD_PLATFORM="linux/amd64,linux/arm64"
        BUILD_CACHE_KEY="(roadrunner@$(get_github_latest_tag "roadrunner-server/roadrunner" | head -c19))"
        ALLOW_RC=1
        ;;
    app-*)
        APP_NAME="${APP#app-}"
        BUILD_NAME="$DEFAULT_REPO/$APP_NAME"
        BUILD_DOCKERFILE="$BASE_DIR/src/webapps/$APP_NAME/$APP_NAME.dockerfile"
        PHP_VARIANT="fpm$SUFFIX"
        apply_app_rules "$APP_NAME"
        BUILD_CACHE_KEY="($BUILD_FROM_IMAGE@$(get_dockerhub_latest_sha "$BUILD_FROM_IMAGE" 1 "php${PHP_VERSION%-rc}${SUFFIX}" | head -c19))"
        ;;
    *)
        S6_VERSION=
        BUILD_FROM_IMAGE=php
        BUILD_DOCKERFILE="$BASE_DIR/src/php/base-php.dockerfile"
        PHP_VARIANT="$APP$SUFFIX"
        ALLOW_RC=1
        ;;
esac

################################################################################
# Skip build checks
################################################################################
# Skip build if the latest supported PHP version is less than the build version
if [ "$ALLOW_RC" != "1" ]; then
        verlt "$LATEST_PHP" "$PHP_VERSION" && SKIP_BUILD=1
fi

# Skip build if the PHP version is earlier than 7.1 and the OS is Alpine
if [ -n "$PHP_VERSION" ] && verlt "$PHP_VERSION" "7.1" && [ "$OS_BASE" = "alpine" ]; then
    BUILD_DOCKERFILE=
    SKIP_BUILD=1
fi

################################################################################
# Lazy load the latest meta versions when necessary
################################################################################
if [ "$SKIP_BUILD" != "1" ]; then
    # Composer
    if [ "$COMPOSER_VERSION" = "latest" ]; then
        COMPOSER_VERSION="$(get_github_latest_tag "composer/composer" 1)"
        if [ -z "$COMPOSER_VERSION" ]; then
            echo "Failed to get the latest Composer version" >&2
            exit 1
        fi
    fi

    # IPE (docker-php-extension-installer)
    if [ "$IPE_VERSION" = "latest" ]; then
        IPE_VERSION="$(get_github_latest_tag "mlocati/docker-php-extension-installer" 1)"
        if [ -z "$IPE_VERSION" ]; then
            echo "Failed to get the latest docker-php-extension-installer version" >&2
            exit 1
        fi
    fi

    # s6-overlay
    if [ "$S6_VERSION" = "latest" ]; then
        LATEST_S6="$(get_github_latest_tag "just-containers/s6-overlay" 1)"
        if [ -z "$LATEST_S6" ]; then
            echo "Failed to get the latest s6-overlay version" >&2
            exit 1
        fi
        S6_VERSION="$LATEST_S6"
    fi
fi

################################################################################
# Generate build tags
################################################################################
expand_tags() {
    local find="$1" add="$2" exclude="${3:-dummy}" out=""
    for item in ${BUILD_TAGS//,/ }; do
        out+="${out:+,}$item"
        if [[ "$item" != *"$exclude"* ]] && echo "$item" | grep -Eq "$find"; then
            out+="${out:+,}${item/$find/$add}"
        fi
    done
    BUILD_TAGS="$out"
}

add_tag() {
    for tag; do
        [ -n "$tag" ] && BUILD_TAGS="${BUILD_TAGS:+$BUILD_TAGS,}$tag"
    done
}

# Generate build tags
if [ -n "$PHP_VERSION" ]; then
    if [ "$BUILD_NAME" = "$DEFAULT_BUILD_NAME" ]; then
        add_tag "$BUILD_NAME:$PHP_VERSION-$PREFIX$SUFFIX"
        [ "$PHP_VERSION" = "$LATEST_PHP" ] && add_tag "$BUILD_NAME:$PREFIX$SUFFIX"

        if [ "$PREFIX" = "cli" ]; then
            add_tag "$BUILD_NAME:$PHP_VERSION$SUFFIX"
            [ "$PHP_VERSION" = "$LATEST_PHP" ] && add_tag "$BUILD_NAME:latest$SUFFIX"
        fi

    elif [ "${APP#with-}" != "$APP" ]; then
        add_tag "$BUILD_NAME:php$PHP_VERSION$SUFFIX"
        [ "$PHP_VERSION" = "$LATEST_PHP" ] && add_tag "$BUILD_NAME:latest$SUFFIX"

        case "$APP" in
            with-apache)     suffix=fpm-apache ;;
            with-nginx)      suffix=fpm-nginx ;;
            with-roadrunner) suffix=roadrunner ;;
            with-f8p)        suffix=frankenphp ;;
            with-unit)       suffix=unit-php ;;
        esac

        [ -n "$suffix" ] && {
            expand_tags "$BUILD_NAME:latest" "$DEFAULT_BUILD_NAME:$suffix"
            expand_tags "$BUILD_NAME:php$PHP_VERSION" "$DEFAULT_BUILD_NAME:$PHP_VERSION-$suffix"
        }
    elif [ "${APP#app-}" != "$APP" ]; then
        if [ -z "$PREFER_SERVER" ] || [ "$PREFER_SERVER" = "$USE_SERVER" ]; then
            add_tag "$BUILD_NAME:php$PHP_VERSION$SUFFIX"
            [ "$PHP_VERSION" = "$LATEST_PHP" ] && add_tag "$BUILD_NAME:latest$SUFFIX"
        fi
        SERVER_SUFFIX="${PREFER_SERVER:+-$PREFER_SERVER}"
        add_tag "$BUILD_NAME:php$PHP_VERSION$SERVER_SUFFIX$SUFFIX"
    fi

    # Alias major versions
    case "$PHP_VERSION" in
        5.6)
            expand_tags ":php5.6" ":php5"
            expand_tags ":5.6" ":5"
            ;;
        7.4)
            expand_tags ":php7.4" ":php7"
            expand_tags ":7.4" ":7"
            ;;
        8.4)
            expand_tags ":php8.4" ":php8"
            expand_tags ":8.4" ":8"
            ;;
        "$LATEST_PHP")
            major=${PHP_VERSION%%.*}
            expand_tags ":php$PHP_VERSION" ":php$major"
            expand_tags ":$PHP_VERSION" ":$major"
            ;;
    esac
elif [ "$APP" = "base-s6" ]; then
    add_tag "$BUILD_NAME:$S6_VERSION" "$BUILD_NAME:latest"
else
    add_tag "$BUILD_NAME:s6-$S6_VERSION" "$BUILD_NAME:latest"
fi

# Remove alpha or rc versions from build tags
BUILD_TAGS="${BUILD_TAGS//-rc/}"

# Apply tag prefix for development branch
if [ -n "$BUILD_TAG_PREFIX" ]; then
    BUILD_TAGS="${BUILD_TAGS//:/:$BUILD_TAG_PREFIX}"
    [ "$BUILD_FROM_IMAGE" != "$BASE_REPO" ] && BUILD_FROM_IMAGE="${BUILD_FROM_IMAGE//:/:$BUILD_TAG_PREFIX}"
fi

[ -z "$BUILD_TAGS" ] && { echo "Failed to generate build tags" >&2; exit 1; }
BUILD_TAG="${BUILD_TAGS%%,*}"

[ -z "$BUILD_TAG_PREFIX" ] && expand_tags ":" ":dev-"
[ "$PUBLISH_TO_GHCR" = "1" ] && expand_tags "$DEFAULT_REPO" "ghcr.io/$DEFAULT_REPO"

if [ -n "$ARCHIVES_REPO" ] && [ -z "$BUILD_TAG_PREFIX" ]; then
    unique_id="$(date +%Y%m%d)"
    expand_tags "${DEFAULT_BUILD_NAME}:" "${ARCHIVES_REPO}:${unique_id}-" ":dev-"
fi

unset suffix SERVER_SUFFIX major unique_id

################################################################################
# Build context, readme, description etc.
################################################################################
if [ "$DUMMY" = "1" ]; then
    BUILD_DOCKERFILE="$BASE_DIR/src/dummy.dockerfile"
    BUILD_CACHE_KEY="(dummy@$BUILD_REVISION)"
fi

if [ -n "$BUILD_DOCKERFILE" ] && [ -f "$BUILD_DOCKERFILE" ]; then
    BUILD_DOCKERFILE_SQUASHED="/tmp/squashed-$(basename "$BUILD_DOCKERFILE")"
    BUILD_CONTEXT="$(dirname "$BUILD_DOCKERFILE")"

    [ ! -d "$BUILD_CONTEXT/rootfs" ] && mkdir -p "$BUILD_CONTEXT/rootfs"
    [ ! -e "$BUILD_CONTEXT/meta.dockerfile" ] && \
        cp -pf "$BASE_DIR/src/php/meta.dockerfile" "$BUILD_CONTEXT/meta.dockerfile"

    if [ -f "$BUILD_CONTEXT/README.md" ]; then
        BUILD_README="$BUILD_CONTEXT/README.md"
    else
        BUILD_README="${BUILD_DOCKERFILE%.*}.md"
    fi
else
    BUILD_DOCKERFILE_SQUASHED=
    BUILD_DOCKERFILE=
    BUILD_CONTEXT=
fi

# Main README.md
if [ "$BUILD_NAME" = "$DEFAULT_BUILD_NAME" ] && \
    [ "$APP" = "cli" ] && [ "$PHP_VERSION" = "$LATEST_PHP" ]; then
    BUILD_README="$DEFAULT_README"
fi

# Parse description from README.md
if [ -n "$BUILD_README" ] && [ -f "$BUILD_README" ]; then
    BUILD_DESC="$(sed '3q;d' "$BUILD_README")"

    # update readme on latest tag and not dev branch
    if [[ "$BUILD_TAGS" == *'latest'* ]] && [ -z "$BUILD_TAG_PREFIX" ]; then
        UPDATE_README=1
    fi
else
    BUILD_README=
    BUILD_DESC="$(sed '3q;d' "$DEFAULT_README")"
fi

# Skip build if there is no Dockerfile
[ -z "$BUILD_DOCKERFILE" ] && SKIP_BUILD=1
[ -z "$BUILD_DOCKERFILE_SQUASHED" ] && SKIP_SQUASH=1

################################################################################
# Cache key
################################################################################
if [ ! -e "$BUILD_CACHE_PATH" ]; then
    mkdir -p "$BUILD_CACHE_PATH" 2>&1
    mkdir -p "${BUILD_CACHE_PATH}-new" 2>&1
fi

if [ "$SKIP_BUILD" != "1" ]; then
    BUILD_CACHE_KEY="($APP@$BUILD_TAG)${BUILD_CACHE_KEY:+/}$BUILD_CACHE_KEY"

    [ -n "$S6_VERSION" ] && BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(s6@$S6_VERSION)"

    if [ -n "$OS_BASE" ]; then
        OS_SHA="$(get_dockerhub_latest_sha "library/$OS_BASE" 1 "$OS_VERSION" | head -c19)"
        BUILD_CACHE_KEY="$BUILD_CACHE_KEY/($OS_BASE:$OS_VERSION@$OS_SHA)"
    fi

    if [ -n "$PHP_VERSION" ]; then
        PHP_SHA="$(get_dockerhub_latest_sha "library/php" 1 "$PHP_VERSION-${PHP_VARIANT#-}" | head -c19)"
        BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(php:$PHP_VERSION-${PHP_VARIANT#-}@$PHP_SHA)/(IPE:$IPE_VERSION)/(composer:$COMPOSER_VERSION)"
    fi

    BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(buildfile:$(path_hash "$BUILD_DOCKERFILE" | head -c10))"
    BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(buildcontext:$(path_hash "$BUILD_CONTEXT" | shasum | head -c10))"
    BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(workflows:$(path_hash "$BASE_DIR/.github/workflows/template-"* | shasum | head -c10))"
else
    BUILD_CACHE_KEY=""
fi

BUILD_TMP_NAME="localhost:5000/$(path_hash "$BUILD_CACHE_KEY" | head -c10)"

################################################################################
# Fix build platforms
################################################################################
remove_platform() {
    local platforms="$1"
    local new_string
    shift
    for search; do
        for item in ${platforms//,/ }; do
            [[ "$item" != *"$search"* ]] && new_string="${new_string:+$new_string,}$item"
        done
        platforms="$new_string"
        unset new_string
    done
    echo "$platforms"
}

# Remove some platforms for older PHP versions
if [ -n "$PHP_VERSION" ]; then
    if verlt "$PHP_VERSION" "7.1"; then
        BUILD_PLATFORM="linux/amd64,linux/arm/v7"
    elif [ "$OS_BASE" = "debian" ] && verlt "$PHP_VERSION" "8.1"; then
        BUILD_PLATFORM="$(remove_platform "$BUILD_PLATFORM" 'ppc64le' 's390x')"
    fi
fi

################################################################################
# Temporary fix for Debian 13 (Trixie)
# See: https://github.com/mlocati/docker-php-extension-installer/issues/1141
################################################################################
if [ "$OS_BASE" = "debian" ] && [ "$BUILD_FROM_IMAGE" = "$BASE_REPO" ] && is_active_version "$PHP_VERSION"; then
    PHP_VARIANT="$PHP_VARIANT-bookworm"
fi

################################################################################
# Fix image name for RC versions
################################################################################
[ "$BUILD_FROM_IMAGE" != "$BASE_REPO" ] && PHP_VERSION="${PHP_VERSION//-rc/}"

################################################################################
# Use mirror repos for pulling docker images
################################################################################
[ -n "$MIRROR_REPO" ] && BUILD_FROM_IMAGE="${BUILD_FROM_IMAGE//$DEFAULT_REPO/$MIRROR_REPO}"

################################################################################
# Correct the PHP variant for apps
################################################################################
[ "${APP:0:4}" = "app-" ] && PHP_VARIANT="$SUFFIX"

################################################################################
# Export Git action environment variables
################################################################################
github_env USE_BUILD_CACHE "$USE_BUILD_CACHE"
github_env BUILD_CACHE_KEY "$BUILD_CACHE_KEY"
github_env BUILD_CACHE_PATH "$BUILD_CACHE_PATH"
github_env BUILD_CONTEXT "$BUILD_CONTEXT"
github_env BUILD_DATE "$BUILD_DATE"
github_env BUILD_DESC "$BUILD_DESC"
github_env BUILD_DOCKERFILE "$BUILD_DOCKERFILE"
github_env BUILD_DOCKERFILE_SQUASHED "$BUILD_DOCKERFILE_SQUASHED"
github_env BUILD_FROM_IMAGE "$BUILD_FROM_IMAGE"
github_env BUILD_NAME "$BUILD_NAME"
github_env BUILD_PLATFORM "$BUILD_PLATFORM"
github_env BUILD_README "$BUILD_README"
github_env BUILD_REVISION "$BUILD_REVISION"
github_env BUILD_SOURCE_IMAGE "$BUILD_SOURCE_IMAGE"
github_env BUILD_TAG "$BUILD_TAG"
github_env BUILD_TAG_PREFIX "$BUILD_TAG_PREFIX"
github_env BUILD_TAGS "$BUILD_TAGS"
github_env BUILD_TMP_NAME "$BUILD_TMP_NAME"
github_env LATEST_PHP "$LATEST_PHP"
github_env LATEST_S6 "$LATEST_S6"
github_env OS_BASE "$OS_BASE"
github_env OS_VERSION "$OS_VERSION"
github_env PHP_VARIANT "$PHP_VARIANT"
github_env PHP_VERSION "$PHP_VERSION"
github_env S6_PATH "$S6_PATH"
github_env S6_VERSION "$S6_VERSION"
github_env SKIP_BUILD "$SKIP_BUILD"
github_env SKIP_SQUASH "$SKIP_SQUASH"
github_env SQUASH_CMD "$SQUASH_CMD"
github_env UPDATE_README "$UPDATE_README"

################################################################################
# Debug
################################################################################
{
    if [ "$SKIP_BUILD" != "1" ]; then
        echo "🐧 Debug:"
        path_hash "$BUILD_CONTEXT"
        path_hash "$BUILD_DOCKERFILE"
        path_hash "$BASE_DIR/.github/workflows/template-"*
    fi
} >&2
