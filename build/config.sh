#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
SQUASH_CMD="$BASE_DIR/build/docker-squash/docker-squash.sh"

set -e
source "$BASE_DIR/build/helpers.sh"

################################################################################
# Parse arguments
################################################################################

# Show usage if no arguments are passed
if [ "$#" -eq 0 ]; then
    echo "Usage: ${0##*/} <os> <app_name> <php_version> [server]" >&2
    exit 1
fi

OS="$1"
APP="$2"
PHP_VERSION="$3"
PREFER_SERVER="$4"

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
BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x"
# BUILD_PLATFORM="linux/amd64,linux/arm/v7,linux/arm64/v8"

SKIP_BUILD="${SKIP_BUILD:-0}"
SKIP_SQUASH="${SKIP_SQUASH:-0}"
USE_BUILD_CACHE="${USE_BUILD_CACHE:-1}"
ALLOW_RC=0
UPDATE_README=0

PREFIX="${APP//app-/}"
SUFFIX=
USE_SERVER=

if [ -n "$OS" ] && [ "$OS" != "debian" ]; then
    SUFFIX="-$OS"
    OS_BASE="$OS"
fi

if [ "$DEBUG" == "1" ]; then
    SKIP_BUILD=1
fi

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
    if [ "$OS_BASE" == "ubuntu" ]; then
        BUILD_PLATFORM="linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x"
    elif [ "$OS_BASE" == "debian" ]; then
        BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x"
    elif [ "$OS_BASE" == "alpine" ]; then
        BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x"
    fi
    ;;
base-s6)
    # only build on alpine
    if [ "$OS_BASE" == "alpine" ]; then
        SKIP_SQUASH=1
        S6_PATH=/s6
        PHP_VERSION=
        IPE_VERSION=
        COMPOSER_VERSION=
        BUILD_NAME="$DEFAULT_REPO/s6-overlay"
        BUILD_DOCKERFILE="$BASE_DIR/src/php/base-s6.dockerfile"
        BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x"
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
    # https://docs.roadrunner.dev/docs/general/install
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
    # implement later
    APP_NAME="${APP//app-/}"
    USE_SERVER=apache
    BUILD_NAME="$DEFAULT_REPO/$APP_NAME"
    BUILD_DOCKERFILE="$BASE_DIR/src/webapps/$APP_NAME/$APP_NAME.dockerfile"
    PHP_VARIANT="fpm$SUFFIX"

    # disable cache because there are too many useless cache keys
    # USE_BUILD_CACHE=0

    case "$APP_NAME" in
    bedrock)
        # https://roots.io/bedrock/docs/installation
        verlt "$PHP_VERSION" "8.0" && SKIP_BUILD=1
        USE_SERVER="" PREFER_SERVER=""
        BUILD_FROM_IMAGE="$DEFAULT_REPO/wordpress"
        ;;
    cakephp4)
        # https://book.cakephp.org/4/en/installation.html
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        LATEST_PHP="8.3"
        ;;
    cakephp5)
        # https://book.cakephp.org/5/en/installation.html
        verlt "$PHP_VERSION" "8.1" && SKIP_BUILD=1
        ;;
    codeigniter4)
        # https://codeigniter.com/user_guide/installation/index.html
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        ;;
    coolify)
        # https://coolify.io/docs/installation
        verlt "$PHP_VERSION" "8.2" && SKIP_BUILD=1
        USE_SERVER="" PREFER_SERVER=""
        BUILD_FROM_IMAGE="$DEFAULT_REPO/laravel"
        ;;
    drupal)
        # https://www.drupal.org/docs/getting-started/system-requirements/php-requirements
        verlt "$PHP_VERSION" "8.0" && SKIP_BUILD=1
        ;;
    espocrm)
        # https://docs.espocrm.com/administration/installation
        verlt "$PHP_VERSION" "8.1" && SKIP_BUILD=1
        ;;
    flarum)
        # https://docs.flarum.org/install
        verlt "$PHP_VERSION" "7.3" && SKIP_BUILD=1
        USE_SERVER="nginx"
        ;;
    flightphp)
        # https://docs.flightphp.com
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        USE_SERVER="nginx"
        ;;
    grav)
        # https://learn.getgrav.org/17/basics/installation
        verlt "$PHP_VERSION" "7.3" && SKIP_BUILD=1
        ;;
    hyperf)
        # https://hyperf.wiki/3.1/#/en/quick-start/install
        LATEST_PHP="8.3"
        USE_SERVER="nginx"
        BUILD_PLATFORM="linux/amd64,linux/arm/v7,linux/arm64/v8"
        verlt "$PHP_VERSION" "7.2" && SKIP_BUILD=1
        if verlte "8.3" "$PHP_VERSION"; then
            BUILD_PLATFORM="linux/amd64,linux/arm64/v8"
        fi
        ;;
    hypervel)
        # https://hypervel.org/docs/deployment
        USE_SERVER="" PREFER_SERVER=""
        BUILD_FROM_IMAGE="$DEFAULT_REPO/laravel"
        BUILD_PLATFORM="linux/amd64,linux/arm/v7,linux/arm64/v8"
        verlt "$PHP_VERSION" "8.2" && SKIP_BUILD=1
        if verlte "8.3" "$PHP_VERSION"; then
            BUILD_PLATFORM="linux/amd64,linux/arm64/v8"
        fi
        ;;
    invoiceshelf)
        # https://docs.invoiceshelf.com/install/manual.html
        verlt "$PHP_VERSION" "8.1" && SKIP_BUILD=1
        USE_SERVER="" PREFER_SERVER=""
        BUILD_FROM_IMAGE="$DEFAULT_REPO/laravel"
        ;;
    kirby)
        # https://getkirby.com/docs/cookbook/setup/composer
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        ;;
    laminas)
        # https://docs.laminas.dev/tutorials/getting-started/skeleton-application
        verlt "$PHP_VERSION" "7.3" && SKIP_BUILD=1
        LATEST_PHP="8.3"
        USE_SERVER="nginx"
        ;;
    laravel)
        # https://laravel.com/docs/master/installation
        USE_SERVER="nginx"
        ;;
    magento)
        # https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        LATEST_PHP="8.3"
        USE_SERVER="nginx"
        ;;
    mautic)
        # https://docs.mautic.org/en/5.x/getting_started/how_to_install_mautic.html#installing-with-composer
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        LATEST_PHP="8.3"
        ;;
    phpmyadmin)
        # https://docs.phpmyadmin.net/en/latest/setup.html
        USE_SERVER="nginx"
        ;;
    slim)
        # https://www.slimframework.com/docs/v4/start/installation.html
        ;;
    spiral)
        # https://spiral.dev/docs/start-installation/current/en
        verlt "$PHP_VERSION" "8.1" && SKIP_BUILD=1
        PHP_VARIANT="cli$SUFFIX"
        USE_SERVER="roadrunner"
        BUILD_PLATFORM="linux/amd64,linux/arm64"
        ;;
    statamic)
        # https://statamic.dev/installing
        verlt "$PHP_VERSION" "7.2" && SKIP_BUILD=1
        USE_SERVER="" PREFER_SERVER=""
        BUILD_FROM_IMAGE="$DEFAULT_REPO/laravel"
        ;;
    symfony)
        # https://symfony.com/doc/current/setup.html
        ;;
    sulu)
        # https://github.com/sulu/skeleton
        USE_SERVER="" PREFER_SERVER=""
        BUILD_FROM_IMAGE="$DEFAULT_REPO/symfony"
        ;;
    wordpress)
        # https://wordpress.org/documentation/category/installation
        ALLOW_RC=1
        ;;
    yii)
        # https://www.yiiframework.com/doc/guide/2.0/en/start-installation
        ;;

    ## Inactive frameworks
    crater) SKIP_BUILD=1 ;;
    # crater)
    #     # https://docs.craterapp.com/installation.html
    #     verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
    #     LATEST_PHP="8.1"
    #     USE_SERVER="" PREFER_SERVER=""
    #     BUILD_FROM_IMAGE="$DEFAULT_REPO/laravel"
    #     ;;
    fuelphp) SKIP_BUILD=1 ;;
    # fuelphp)
    #     # https://fuelphp.com/docs/installation/instructions.html
    #     LATEST_PHP="8.0"
    #     ;;
    phpixie) SKIP_BUILD=1 ;;
    # phpixie)
    #     # https://phpixie.com/quickstart.html
    #     LATEST_PHP="7.4"
    #     ;;

    esac

    # override the default server variant
    case "${PREFER_SERVER:-$USE_SERVER}" in
    httpd | apache*)
        PREFER_SERVER="apache"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-apache"
        ;;
    nginx)
        PREFER_SERVER="nginx"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        ;;
    unit | nginx-unit)
        PREFER_SERVER="unit"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/unit-php"
        ;;
    f8p | frankenphp)
        PREFER_SERVER="frankenphp"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/frankenphp"
        ;;
    rr | roadrunner)
        PREFER_SERVER="roadrunner"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/roadrunner"
        ;;
    *)
        PREFER_SERVER=""
        ;;
    esac

    # get checksum of the base image
    BUILD_CACHE_KEY="($BUILD_FROM_IMAGE@$(get_dockerhub_latest_sha "$BUILD_FROM_IMAGE" 1 "php${PHP_VERSION//-rc/}${SUFFIX}" | head -c19))"
    ;;

*)
    # default
    S6_VERSION=
    BUILD_FROM_IMAGE=php
    BUILD_DOCKERFILE="$BASE_DIR/src/php/base-php.dockerfile"
    PHP_VARIANT="$APP$SUFFIX"
    ALLOW_RC=1
    ;;
esac

# Skip build if the latest supported PHP version is less than the build version
if [ "$ALLOW_RC" != "1" ]; then
    verlt "$LATEST_PHP" "$PHP_VERSION" && SKIP_BUILD=1
fi

# Skip build if the PHP version is earlier than 7.1 and the OS is not Debian
if [ -n "$PHP_VERSION" ] && verlt "$PHP_VERSION" "7.1" && [ "$OS_BASE" != "debian" ]; then
    BUILD_DOCKERFILE=
    SKIP_BUILD=1
fi

# Lazy load the latest meta version when necessary
if [ "$SKIP_BUILD" != "1" ]; then
    # the latest Composer version
    if [ "$COMPOSER_VERSION" == "latest" ]; then
        COMPOSER_VERSION="$(get_github_latest_tag "composer/composer" 1)"
        if [ -z "$COMPOSER_VERSION" ]; then
            echo "Failed to get the latest Composer version" >&2
            exit 1
        fi
    fi

    # the latest IPE version
    if [ "$IPE_VERSION" == "latest" ]; then
        IPE_VERSION="$(get_github_latest_tag "mlocati/docker-php-extension-installer" 1)"
        if [ -z "$IPE_VERSION" ]; then
            echo "Failed to get the latest docker-php-extension-installer version" >&2
            exit 1
        fi
    fi

    # the latest s6-overlay version
    if [ "$S6_VERSION" == "latest" ]; then
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

append_tags() {
    local search="$1"
    local replace="$2"
    local csv_string="$3"
    local exclude="${4:-dummy}"
    local new_string=""
    for item in ${csv_string//,/ }; do
        new_string+="${new_string:+,}$item"
        if echo "$item" | grep -v "$exclude" | grep -Eq "$search"; then
            local new_item="${item/$search/$replace}"
            new_string+="${new_string:+,}$new_item"
        fi
    done
    echo "$new_string"
}

# Generate build tags
if [ -n "$PHP_VERSION" ]; then
    if [ "$BUILD_NAME" == "$DEFAULT_BUILD_NAME" ]; then
        BUILD_TAGS="$BUILD_NAME:$PHP_VERSION-$PREFIX$SUFFIX"
        if [ "$PHP_VERSION" == "$LATEST_PHP" ]; then
            BUILD_TAGS="$BUILD_TAGS,$BUILD_NAME:$PREFIX$SUFFIX"
        fi
        if [ "$PREFIX" == "cli" ]; then
            BUILD_TAGS="$BUILD_TAGS,$BUILD_NAME:$PHP_VERSION$SUFFIX"
            if [ "$PHP_VERSION" == "$LATEST_PHP" ]; then
                BUILD_TAGS="$BUILD_TAGS,$BUILD_NAME:latest$SUFFIX"
            fi
        fi
    elif [ "${APP:0:5}" == "with-" ]; then
        BUILD_TAGS="$BUILD_NAME:php$PHP_VERSION$SUFFIX"
        if [ "$PHP_VERSION" == "$LATEST_PHP" ]; then
            BUILD_TAGS="$BUILD_TAGS,$BUILD_NAME:latest$SUFFIX"
        fi
        case "$APP" in
        with-apache)
            BUILD_TAGS="$(append_tags "$BUILD_NAME:latest" "$DEFAULT_BUILD_NAME:fpm-apache" "$BUILD_TAGS")"
            BUILD_TAGS="$(append_tags "$BUILD_NAME:php$PHP_VERSION" "$DEFAULT_BUILD_NAME:$PHP_VERSION-fpm-apache" "$BUILD_TAGS")"
            ;;
        with-nginx)
            BUILD_TAGS="$(append_tags "$BUILD_NAME:latest" "$DEFAULT_BUILD_NAME:fpm-nginx" "$BUILD_TAGS")"
            BUILD_TAGS="$(append_tags "$BUILD_NAME:php$PHP_VERSION" "$DEFAULT_BUILD_NAME:$PHP_VERSION-fpm-nginx" "$BUILD_TAGS")"
            ;;
        with-roadrunner)
            BUILD_TAGS="$(append_tags "$BUILD_NAME:latest" "$DEFAULT_BUILD_NAME:roadrunner" "$BUILD_TAGS")"
            BUILD_TAGS="$(append_tags "$BUILD_NAME:php$PHP_VERSION" "$DEFAULT_BUILD_NAME:$PHP_VERSION-roadrunner" "$BUILD_TAGS")"
            ;;
        with-f8p)
            BUILD_TAGS="$(append_tags "$BUILD_NAME:latest" "$DEFAULT_BUILD_NAME:frankenphp" "$BUILD_TAGS")"
            BUILD_TAGS="$(append_tags "$BUILD_NAME:php$PHP_VERSION" "$DEFAULT_BUILD_NAME:$PHP_VERSION-frankenphp" "$BUILD_TAGS")"
            ;;
        with-unit)
            BUILD_TAGS="$(append_tags "$BUILD_NAME:latest" "$DEFAULT_BUILD_NAME:unit-php" "$BUILD_TAGS")"
            BUILD_TAGS="$(append_tags "$BUILD_NAME:php$PHP_VERSION" "$DEFAULT_BUILD_NAME:$PHP_VERSION-unit-php" "$BUILD_TAGS")"
            ;;
        esac
    elif [ "${APP:0:4}" == "app-" ]; then
        SERVER_SUFFIX=""
        if [ -n "$PREFER_SERVER" ]; then
            SERVER_SUFFIX="-$PREFER_SERVER"
        fi
        BUILD_TAGS="$BUILD_NAME:php$PHP_VERSION$SERVER_SUFFIX$SUFFIX"
        if [ -z "$PREFER_SERVER" ] || [ "$PREFER_SERVER" == "$USE_SERVER" ]; then
            [ "$PHP_VERSION" == "$LATEST_PHP" ] && BUILD_TAGS="$BUILD_TAGS,$BUILD_NAME:latest$SUFFIX"
        fi
    fi

    case "$PHP_VERSION" in
    "5.6")
        BUILD_TAGS="$(append_tags ":php$PHP_VERSION" ":php5" "$BUILD_TAGS")"
        BUILD_TAGS="$(append_tags ":$PHP_VERSION" ":5" "$BUILD_TAGS")"
        ;;
    "7.4")
        BUILD_TAGS="$(append_tags ":php$PHP_VERSION" ":php7" "$BUILD_TAGS")"
        BUILD_TAGS="$(append_tags ":$PHP_VERSION" ":7" "$BUILD_TAGS")"
        ;;
    "8.4")
        BUILD_TAGS="$(append_tags ":php$PHP_VERSION" ":php8" "$BUILD_TAGS")"
        BUILD_TAGS="$(append_tags ":$PHP_VERSION" ":8" "$BUILD_TAGS")"
        ;;
    "$LATEST_PHP")
        BUILD_TAGS="$(append_tags ":php$PHP_VERSION" ":php${PHP_VERSION%%.*}" "$BUILD_TAGS")"
        BUILD_TAGS="$(append_tags ":$PHP_VERSION" ":${PHP_VERSION%%.*}" "$BUILD_TAGS")"
        ;;
    esac
elif [ "$APP" == "base-s6" ]; then
    BUILD_TAGS="$BUILD_NAME:$S6_VERSION,$BUILD_NAME:latest"
else
    BUILD_TAGS="$BUILD_NAME:s6-$S6_VERSION,$BUILD_NAME:latest"
fi

# Remove alpha or rc versions from build tags
BUILD_TAGS="${BUILD_TAGS//-rc/}"

# Apply tag prefix for development branch
if [ -n "$BUILD_TAG_PREFIX" ]; then
    BUILD_TAGS="${BUILD_TAGS//:/:$BUILD_TAG_PREFIX}"

    if [ "$BUILD_FROM_IMAGE" != "$BASE_REPO" ]; then
        BUILD_FROM_IMAGE="${BUILD_FROM_IMAGE//:/:$BUILD_TAG_PREFIX}"
    fi
fi

# Check if build tags are empty
if [ -z "$BUILD_TAGS" ]; then
    echo "Failed to generate build tags" 1>&2
    exit 1
else
    BUILD_TAG="$(echo $BUILD_TAGS | cut -d, -f1)"
fi

# Find tag contains "-alpine" and appends tags with "tidy"
# If [ "$OS_BASE" == "alpine" ]; then
#     BUILD_TAGS="$(append_tags "-$OS_BASE" "-tidy" "$BUILD_TAGS")"
# Fi

# Also tag 'dev-' variants when the tag prefix is empty
if [ -z "$BUILD_TAG_PREFIX" ]; then
    BUILD_TAGS="$(append_tags ":" ":dev-" "$BUILD_TAGS")"
fi

# Also publish to ghcr.io
if [ "$PUBLISH_TO_GHCR" == "1" ]; then
    BUILD_TAGS="$(append_tags "$DEFAULT_REPO" "ghcr.io/$DEFAULT_REPO" "$BUILD_TAGS")"
fi

# Also push a copy to archived repo
if [ -n "$ARCHIVES_REPO" ] && [ -z "$BUILD_TAG_PREFIX" ]; then
    unique_id="$(date +%Y%m%d)"
    BUILD_TAGS="$(append_tags "${DEFAULT_BUILD_NAME}:" "${ARCHIVES_REPO}:${unique_id}-" "$BUILD_TAGS" ":dev-")"
fi

################################################################################
# Build context, readme, description etc.
################################################################################

if [ "$DUMMY" == "1" ]; then
    BUILD_DOCKERFILE="$BASE_DIR/src/dummy.dockerfile"
    BUILD_CACHE_KEY="(dummy@$BUILD_REVISION)"
fi

if [ -n "$BUILD_DOCKERFILE" ] && [ -f "$BUILD_DOCKERFILE" ]; then
    BUILD_DOCKERFILE_SQUASHED="/tmp/squashed-$(basename "$BUILD_DOCKERFILE")"
    BUILD_CONTEXT="$(dirname "$BUILD_DOCKERFILE")"

    if [ ! -d "$BUILD_CONTEXT/rootfs" ]; then
        mkdir -p "$BUILD_CONTEXT/rootfs"
    fi

    if [ ! -e "$BUILD_CONTEXT/meta.dockerfile" ]; then
        cp -pf "$BASE_DIR/src/php/meta.dockerfile" "$BUILD_CONTEXT/meta.dockerfile"
    fi

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
if [ "$BUILD_NAME" == "$DEFAULT_BUILD_NAME" ] && [ "$APP" == "cli" ] && [ "$PHP_VERSION" == "$LATEST_PHP" ]; then
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

# Skip build if no dockerfile files
if [ -z "$BUILD_DOCKERFILE" ]; then
    SKIP_BUILD=1
fi

# Skip squash if no dockerfile
if [ -z "$BUILD_DOCKERFILE_SQUASHED" ]; then
    SKIP_SQUASH=1
fi

################################################################################
# Cache key
################################################################################

if [ ! -e "$BUILD_CACHE_PATH" ]; then
    mkdir -p "$BUILD_CACHE_PATH" 2>&1
    mkdir -p "${BUILD_CACHE_PATH}-new" 2>&1
fi

if [ "$SKIP_BUILD" != "1" ]; then
    BUILD_CACHE_KEY="($APP@$BUILD_TAG)${BUILD_CACHE_KEY:+/}$BUILD_CACHE_KEY"

    if [ -n "$S6_VERSION" ]; then
        BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(s6@$S6_VERSION)"
    fi

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
            if [[ "$item" != *"$search"* ]]; then
                new_string+="${new_string:+,}$item"
            fi
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
    elif [ "$OS_BASE" == "debian" ] && verlt "$PHP_VERSION" "8.1"; then
        BUILD_PLATFORM="$(remove_platform "$BUILD_PLATFORM" 'ppc64le' 's390x')"
    fi
fi

################################################################################
# Temporary fix for Debian 13 (Trixie)
# See: https://github.com/mlocati/docker-php-extension-installer/issues/1141
################################################################################

if [ "$OS_BASE" == "debian" ] && [ "$BUILD_FROM_IMAGE" == "$BASE_REPO" ] && is_active_version "$PHP_VERSION"; then
    PHP_VARIANT="$PHP_VARIANT-bookworm"
fi

################################################################################
# Fix image name for RC versions
################################################################################

# Remove -rc from PHP_VERSION
if [ "$BUILD_FROM_IMAGE" != "$BASE_REPO" ]; then
    PHP_VERSION="${PHP_VERSION//-rc/}"
fi

################################################################################
# Use mirror repos for pulling docker images
################################################################################

if [ -n "$MIRROR_REPO" ]; then
    BUILD_FROM_IMAGE="${BUILD_FROM_IMAGE//$DEFAULT_REPO/$MIRROR_REPO}"
fi

################################################################################
# Correct the PHP variant for apps
################################################################################

if [ "${APP:0:4}" == "app-" ]; then
    PHP_VARIANT="$SUFFIX"
fi

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
