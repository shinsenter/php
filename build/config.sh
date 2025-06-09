#!/bin/bash
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
. $BASE_DIR/build/helpers.sh
SQUASH_CMD="$BASE_DIR/build/docker-squash/docker-squash.sh"

set -e

################################################################################
# Parse arguments
################################################################################

# Show usage if no arguments are passed
if [ $# -eq 0 ]; then
    echo "Usage: ${0##*/} <os> <app_name> <php_version> [server]" >&2
    exit 1
fi

OS=$1
APP=$2
PHP_VERSION=$3
USE_SERVER=$4

################################################################################
# Build environment variables
################################################################################

DEFAULT_REPO="shinsenter"
DEFAULT_BUILD_NAME="$DEFAULT_REPO/php"
DEFAULT_README="$BASE_DIR/README.md"
UPDATE_README=0

LATEST_PHP="8.4"
LATEST_S6=
ALLOW_RC=0

PHP_VARIANT="${PHP_VARIANT:-}"
S6_VERSION="${S6_VERSION:-latest}"
S6_PATH="${S6_PATH:-}"
OS_BASE="${OS_BASE:-debian}"
OS_VERSION="${OS_VERSION:-latest}"
IPE_VERSION="${IPE_VERSION:-latest}"
COMPOSER_VERSION="${COMPOSER_VERSION:-latest}"

BUILD_NAME="$DEFAULT_BUILD_NAME"
BUILD_DATE="$(date +%Y-%m-%dT%T%z)"
BUILD_REVISION="$(git rev-parse HEAD)"
BUILD_FROM_IMAGE=$DEFAULT_BUILD_NAME
BUILD_SOURCE_IMAGE=
BUILD_CONTEXT=
BUILD_DOCKERFILE=
BUILD_DOCKERFILE_SQUASHED=
BUILD_README=
BUILD_DESC=
BUILD_TAG=
BUILD_TAGS=
BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}
BUILD_TMP_NAME=
BUILD_CACHE_KEY=
BUILD_CACHE_PATH="/tmp/.buildx-cache"
BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x"
# BUILD_PLATFORM="linux/amd64,linux/arm/v7,linux/arm64/v8"
SKIP_BUILD=${SKIP_BUILD:-}
SKIP_SQUASH=${SKIP_SQUASH:-}
USE_BUILD_CACHE=${USE_BUILD_CACHE:-1}

MIRROR_REPO="${MIRROR_REPO:-ghcr.io/shinsenter}"
PREFIX="${APP//app-/}"
SUFFIX=

if [ "$OS" != "" ]; then
    SUFFIX="-$OS"
    OS_BASE="$OS"
fi

if [ "$DEBUG" == "1" ]; then
    SKIP_BUILD=1
fi

################################################################################
# Initialize build variables
################################################################################

case $APP in
base-os)
    BUILD_NAME="$DEFAULT_REPO/$OS_BASE-s6"
    BUILD_DOCKERFILE=$BASE_DIR/src/php/base-os.dockerfile
    PHP_VERSION=
    IPE_VERSION=
    COMPOSER_VERSION=
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
        BUILD_NAME="$DEFAULT_REPO/s6-overlay"
        S6_PATH=/s6
        BUILD_DOCKERFILE=$BASE_DIR/src/php/base-s6.dockerfile
        PHP_VERSION=
        IPE_VERSION=
        COMPOSER_VERSION=
        SKIP_SQUASH=1
        BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x"
    fi
    ;;
with-apache)
    PREFIX="fpm-apache"
    BUILD_NAME="$DEFAULT_REPO/phpfpm-apache"
    BUILD_DOCKERFILE=$BASE_DIR/src/php/with-apache.dockerfile
    PHP_VARIANT="fpm$SUFFIX"
    ALLOW_RC=1
    ;;
with-nginx)
    PREFIX="fpm-nginx"
    BUILD_NAME="$DEFAULT_REPO/phpfpm-nginx"
    BUILD_DOCKERFILE=$BASE_DIR/src/php/with-nginx.dockerfile
    PHP_VARIANT="fpm$SUFFIX"
    ALLOW_RC=1
    ;;
with-unit)
    verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
    unit_version="$(get_github_latest_tag nginx/unit)"
    PREFIX="unit"
    BUILD_NAME="$DEFAULT_REPO/unit-php"
    BUILD_DOCKERFILE=$BASE_DIR/src/php/with-unit.dockerfile
    BUILD_SOURCE_IMAGE="https://codeload.github.com/nginx/unit/tar.gz/refs/tags/$unit_version"
    BUILD_CACHE_KEY="(unit@$(echo "$unit_version" | head -c17))"
    PHP_VARIANT="zts$SUFFIX"
    ALLOW_RC=1
    ;;
with-f8p)
    verlt "$PHP_VERSION" "8.2" && SKIP_BUILD=1
    PREFIX="frankenphp"
    BUILD_NAME="$DEFAULT_REPO/frankenphp"
    BUILD_SOURCE_IMAGE="dunglas/frankenphp:1-php$PHP_VERSION$SUFFIX"
    BUILD_DOCKERFILE=$BASE_DIR/src/php/with-f8p.dockerfile
    BUILD_PLATFORM="linux/386,linux/amd64,linux/arm/v7,linux/arm64/v8"
    BUILD_CACHE_KEY="(frankenphp@$(get_dockerhub_latest_sha "dunglas/frankenphp" 1 "1-php$PHP_VERSION$SUFFIX" | head -c17))"
    PHP_VARIANT="zts$SUFFIX"
    ;;
with-roadrunner)
    verlt "$PHP_VERSION" "8.0" && SKIP_BUILD=1
    # https://docs.roadrunner.dev/docs/general/install
    PREFIX="roadrunner"
    BUILD_NAME="$DEFAULT_REPO/roadrunner"
    BUILD_DOCKERFILE=$BASE_DIR/src/php/with-roadrunner.dockerfile
    PHP_VARIANT="cli$SUFFIX"
    BUILD_PLATFORM="linux/amd64,linux/arm64"
    BUILD_CACHE_KEY="(roadrunner@$(get_github_latest_tag "roadrunner-server/roadrunner" | head -c17))"
    ALLOW_RC=1
    ;;
app-*)
    # implement later
    APP_NAME="${APP//app-/}"
    BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-apache"
    BUILD_NAME="$DEFAULT_REPO/$APP_NAME"
    BUILD_DOCKERFILE=$BASE_DIR/src/webapps/$APP_NAME/$APP_NAME.dockerfile
    PHP_VARIANT="$SUFFIX"

    # disable cache because there are too many useless cache keys
    # USE_BUILD_CACHE=0

    case $APP_NAME in
    cakephp4)
        # https://book.cakephp.org/4/en/installation.html
        LATEST_PHP="8.3"
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
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
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        verlt "$PHP_VERSION" "8.2" && SKIP_BUILD=1
        ;;
    drupal)
        # https://www.drupal.org/docs/getting-started/system-requirements/php-requirements
        verlt "$PHP_VERSION" "8.0" && SKIP_BUILD=1
        ;;
    espocrm)
        # https://docs.espocrm.com/administration/installation/
        verlt "$PHP_VERSION" "8.1" && SKIP_BUILD=1
        ;;
    flarum)
        # https://docs.flarum.org/install/
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        verlt "$PHP_VERSION" "7.3" && SKIP_BUILD=1
        ;;
    grav)
        # https://learn.getgrav.org/17/basics/installation
        verlt "$PHP_VERSION" "7.3" && SKIP_BUILD=1
        ;;
    hyperf)
        # https://hyperf.wiki/3.1/#/en/quick-start/install
        LATEST_PHP="8.3"
        BUILD_PLATFORM="linux/amd64,linux/arm/v7,linux/arm64/v8"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        verlt "$PHP_VERSION" "7.2" && SKIP_BUILD=1
        if verlte "8.3" "$PHP_VERSION"; then
            BUILD_PLATFORM="linux/amd64,linux/arm64/v8"
        fi
        ;;
    invoiceshelf)
        # https://docs.invoiceshelf.com/install/manual.html
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        verlt "$PHP_VERSION" "8.1" && SKIP_BUILD=1
        ;;
    kirby)
        # https://getkirby.com/docs/cookbook/setup/composer
        LATEST_PHP="8.3"
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        ;;
    laminas)
        # https://docs.laminas.dev/tutorials/getting-started/skeleton-application/
        LATEST_PHP="8.3"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        verlt "$PHP_VERSION" "7.3" && SKIP_BUILD=1
        ;;
    laravel)
        # https://laravel.com/docs/master/installation
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        ;;
    magento)
        # https://experienceleague.adobe.com/en/docs/commerce-operations/installation-guide/system-requirements
        LATEST_PHP="8.3"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        ;;
    mautic)
        # https://docs.mautic.org/en/5.x/getting_started/how_to_install_mautic.html#installing-with-composer
        verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
        ;;
    phpmyadmin)
        # https://docs.phpmyadmin.net/en/latest/setup.html
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        ;;
    slim)
        # https://www.slimframework.com/docs/v4/start/installation.html
        ;;
    spiral)
        # https://spiral.dev/docs/start-installation/current/en
        LATEST_PHP="8.3"
        BUILD_FROM_IMAGE="$DEFAULT_REPO/roadrunner"
        BUILD_PLATFORM="linux/amd64,linux/arm64"
        verlt "$PHP_VERSION" "8.1" && SKIP_BUILD=1
        ;;
    statamic)
        # https://statamic.dev/installing
        BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        verlt "$PHP_VERSION" "7.2" && SKIP_BUILD=1
        ;;
    symfony)
        # https://symfony.com/doc/current/setup.html
        ;;
    sulu)
        # https://github.com/sulu/skeleton
        ;;
    wordpress)
        # https://wordpress.org/documentation/category/installation/
        ;;
    bedrock)
        # https://roots.io/bedrock/docs/installation/
        verlt "$PHP_VERSION" "8.0" && SKIP_BUILD=1
        ;;
    yii)
        # https://www.yiiframework.com/doc/guide/2.0/en/start-installation
        ;;

    ## Inactive frameworks
    # crater)
    #     # https://docs.craterapp.com/installation.html
    #     LATEST_PHP="8.1"
    #     BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
    #     verlt "$PHP_VERSION" "7.4" && SKIP_BUILD=1
    #     ;;
    # fuelphp)
    #     # https://fuelphp.com/docs/installation/instructions.html
    #     LATEST_PHP="8.0"
    #     ;;
    # phpixie)
    #     # https://phpixie.com/quickstart.html
    #     LATEST_PHP="7.4"
    #     ;;

    esac

    # override the default server variant
    case "$USE_SERVER" in
    httpd | apache*)
        if [ "$BUILD_FROM_IMAGE" != "$DEFAULT_REPO/phpfpm-apache" ]; then
            SUFFIX="-apache${SUFFIX}"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-apache"
        fi
        ;;
    nginx)
        if [ "$BUILD_FROM_IMAGE" != "$DEFAULT_REPO/phpfpm-nginx" ]; then
            SUFFIX="-nginx${SUFFIX}"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/phpfpm-nginx"
        fi
        ;;
    unit)
        if [ "$BUILD_FROM_IMAGE" != "$DEFAULT_REPO/unit-php" ]; then
            SUFFIX="-unit${SUFFIX}"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/unit-php"
        fi
        ;;
    f8p | frankenphp)
        if [ "$BUILD_FROM_IMAGE" != "$DEFAULT_REPO/frankenphp" ]; then
            SUFFIX="-frankenphp${SUFFIX}"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/frankenphp"
        fi
        ;;
    rr | roadrunner)
        if [ "$BUILD_FROM_IMAGE" != "$DEFAULT_REPO/roadrunner" ]; then
            SUFFIX="-roadrunner${SUFFIX}"
            BUILD_FROM_IMAGE="$DEFAULT_REPO/roadrunner"
        fi
        ;;
    esac

    # get checksum of the base image
    # BUILD_CACHE_KEY="($BUILD_FROM_IMAGE@$(get_dockerhub_latest_sha "$BUILD_FROM_IMAGE" 1 "php$PHP_VERSION" | head -c17))"
    ;;

*)
    # default
    S6_VERSION=
    BUILD_FROM_IMAGE=php
    BUILD_DOCKERFILE=$BASE_DIR/src/php/base-php.dockerfile
    PHP_VARIANT="$APP$SUFFIX"
    ALLOW_RC=1
    ;;
esac

# skip build if the latest supported PHP version is less than the build version
if [ "$ALLOW_RC" != "1" ]; then
    verlt "$LATEST_PHP" "$PHP_VERSION" && SKIP_BUILD=1
fi

# skip build if the PHP version is earlier than 7.1 and the OS is not Debian
if [ "$PHP_VERSION" != "" ] && verlt "$PHP_VERSION" "7.1" && [ "$OS_BASE" != "debian" ]; then
    BUILD_DOCKERFILE=
    SKIP_BUILD=1
fi

# lazy load the latest Composer version when necessary
if [ "$SKIP_BUILD" != "1" ] && [ "$COMPOSER_VERSION" == "latest" ]; then
    COMPOSER_VERSION="$(get_github_latest_tag "composer/composer" 1)"
fi

# lazy load the latest IPE version when necessary
if [ "$SKIP_BUILD" != "1" ] && [ "$IPE_VERSION" == "latest" ]; then
    IPE_VERSION="$(get_github_latest_tag "mlocati/docker-php-extension-installer" 1)"
fi

# lazy load the latest s6-overlay version when necessary
if [ "$SKIP_BUILD" != "1" ] && [ "$S6_VERSION" == "latest" ]; then
    LATEST_S6=$(get_github_latest_tag "just-containers/s6-overlay" 1)
    if [ "$LATEST_S6" == "" ]; then
        echo "Failed to get latest s6-overlay version" >&2
        exit 1
    fi
    S6_VERSION="$LATEST_S6"
fi

################################################################################
# Generate build tags
################################################################################

append_tags() {
    local search=$1
    local replace=$2
    local csv_string=$3
    local exclude=${4:-dummy}
    local new_string=""
    for item in ${csv_string//,/ }; do
        new_string+="${new_string:+,}$item"
        if echo "$item" | grep -v "$exclude" | grep -Eq "$search"; then
            local new_item=${item/$search/$replace}
            new_string+="${new_string:+,}$new_item"
        fi
    done
    echo $new_string
}

# generate build tags
if [ "$PHP_VERSION" != "" ]; then
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
        case $APP in
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
        BUILD_TAGS="$BUILD_NAME:php$PHP_VERSION$SUFFIX"
        if [ "$PHP_VERSION" == "$LATEST_PHP" ]; then
            BUILD_TAGS="$BUILD_TAGS,$BUILD_NAME:latest$SUFFIX"
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

# remove -rc from build tags
BUILD_TAGS=${BUILD_TAGS//-rc/}

# apply tag prefix for development branch
if [ "$BUILD_TAG_PREFIX" != "" ]; then
    BUILD_TAGS=${BUILD_TAGS//:/:$BUILD_TAG_PREFIX}

    if [ "$BUILD_FROM_IMAGE" != "php" ]; then
        BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE//:/:$BUILD_TAG_PREFIX}
    fi
fi

# check if build tags are empty
if [ "$BUILD_TAGS" == "" ]; then
    echo "Failed to generate build tags" 1>&2
    exit 1
else
    BUILD_TAG=$(echo $BUILD_TAGS | cut -d, -f1)
fi

# find tag contains "-alpine" and appends tags with "tidy"
# if [ "$OS_BASE" == "alpine" ]; then
#     BUILD_TAGS="$(append_tags "-$OS_BASE" "-tidy" "$BUILD_TAGS")"
# fi

# also tag 'dev-' variants when the tag prefix is empty
if [ "$BUILD_TAG_PREFIX" == "" ]; then
    BUILD_TAGS="$(append_tags ":" ":dev-" "$BUILD_TAGS")"
fi

# also publish to ghcr.io
if [ "$PUBLISH_TO_GHCR" == "1" ]; then
    BUILD_TAGS="$(append_tags "$DEFAULT_REPO" "ghcr.io/$DEFAULT_REPO" "$BUILD_TAGS")"
fi

# also push a copy to archived repo
if [ "$ARCHIVES_REPO" != "" ] && [ "$BUILD_TAG_PREFIX" == "" ]; then
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

if [ "$BUILD_DOCKERFILE" != "" ] && [ -f $BUILD_DOCKERFILE ]; then
    BUILD_DOCKERFILE_SQUASHED="/tmp/squashed-$(basename $BUILD_DOCKERFILE)"
    BUILD_CONTEXT=$(dirname $BUILD_DOCKERFILE)

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

# main README.md
if [ "$BUILD_NAME" == "$DEFAULT_BUILD_NAME" ] && [ "$APP" == "cli" ] && [ "$PHP_VERSION" == "$LATEST_PHP" ]; then
    BUILD_README=$DEFAULT_README
fi

# parse description from README.md
if [ "$BUILD_README" != "" ] && [ -f "$BUILD_README" ]; then
    BUILD_DESC="$(sed '3q;d' $BUILD_README)"

    # update readme on latest tag and not dev branch
    if [[ "$BUILD_TAGS" == *'latest'* ]] && [ "$BUILD_TAG_PREFIX" == "" ]; then
        UPDATE_README=1
    fi
else
    BUILD_README=
    BUILD_DESC="$(sed '3q;d' $DEFAULT_README)"
fi

# skip build if no dockerfile files
if [ "$BUILD_DOCKERFILE" == "" ]; then
    SKIP_BUILD=1
fi

# skip squash if no dockerfile
if [ "$BUILD_DOCKERFILE_SQUASHED" == "" ]; then
    SKIP_SQUASH=1
fi

################################################################################
# Cache key
################################################################################

if [ ! -e "$BUILD_CACHE_PATH" ]; then
    mkdir -p "$BUILD_CACHE_PATH" 2>&1
    mkdir -p "${BUILD_CACHE_PATH}-new" 2>&1
fi

BUILD_CACHE_KEY="($APP@$BUILD_TAG)${BUILD_CACHE_KEY:+/}$BUILD_CACHE_KEY"

if [ "$S6_VERSION" != "" ]; then
    BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(s6@$S6_VERSION)"
fi

if [ "$OS_BASE" != "" ]; then
    if [ "$SKIP_BUILD" != "1" ]; then
        OS_SHA="$(get_dockerhub_latest_sha "library/$OS_BASE" 1 "$OS_VERSION" | head -c17)"
    fi
    BUILD_CACHE_KEY="$BUILD_CACHE_KEY/($OS_BASE:$OS_VERSION@$OS_SHA)"
fi

if [ "$PHP_VERSION" != "" ]; then
    if [ "$SKIP_BUILD" != "1" ]; then
        PHP_SHA="$(get_dockerhub_latest_sha "library/php" 1 "$PHP_VERSION-${PHP_VARIANT#-}" | head -c17)"
    fi
    BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(php:$PHP_VERSION-${PHP_VARIANT#-}@$PHP_SHA)/(IPE:$IPE_VERSION)/(composer:$COMPOSER_VERSION)"
fi

BUILD_CACHE_KEY="$BUILD_CACHE_KEY/(buildfile:$(path_hash $BUILD_DOCKERFILE | head -c10))\
/(buildcontext:$(path_hash $BUILD_CONTEXT | shasum | head -c10))\
/(workflows:$(path_hash $BASE_DIR/.github/workflows/template-* | shasum | head -c10))"

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
            if [[ $item != *"$search"* ]]; then
                new_string+="${new_string:+,}$item"
            fi
        done
        platforms="$new_string"
        unset new_string
    done
    echo $platforms
}

# remove some platforms for older PHP versions
if [ "$PHP_VERSION" != "" ]; then
    if verlt "$PHP_VERSION" "7.1"; then
        BUILD_PLATFORM="linux/amd64,linux/arm/v7"
    elif [ "$OS_BASE" == "debian" ] && verlt "$PHP_VERSION" "7.3"; then
        BUILD_PLATFORM="$(remove_platform "$BUILD_PLATFORM" '386' 'ppc64le' 's390x')"
    fi
fi

################################################################################
# Fix image name for RC versions
################################################################################

# remove -rc from PHP_VERSION
if [ "$BUILD_FROM_IMAGE" != "php" ]; then
    PHP_VERSION=${PHP_VERSION//-rc/}
fi

################################################################################
# Use mirror repos for pulling docker images
################################################################################

if [ "$MIRROR_REPO" != "" ]; then
    BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE//$DEFAULT_REPO/$MIRROR_REPO}
fi

################################################################################
# Export Git action environment variables
################################################################################

github_env USE_BUILD_CACHE $USE_BUILD_CACHE
github_env BUILD_CACHE_KEY $BUILD_CACHE_KEY
github_env BUILD_CACHE_PATH $BUILD_CACHE_PATH
github_env BUILD_CONTEXT $BUILD_CONTEXT
github_env BUILD_DATE $BUILD_DATE
github_env BUILD_DESC $BUILD_DESC
github_env BUILD_DOCKERFILE $BUILD_DOCKERFILE
github_env BUILD_DOCKERFILE_SQUASHED $BUILD_DOCKERFILE_SQUASHED
github_env BUILD_FROM_IMAGE $BUILD_FROM_IMAGE
github_env BUILD_NAME $BUILD_NAME
github_env BUILD_PLATFORM $BUILD_PLATFORM
github_env BUILD_README $BUILD_README
github_env BUILD_REVISION $BUILD_REVISION
github_env BUILD_SOURCE_IMAGE $BUILD_SOURCE_IMAGE
github_env BUILD_TAG $BUILD_TAG
github_env BUILD_TAG_PREFIX $BUILD_TAG_PREFIX
github_env BUILD_TAGS $BUILD_TAGS
github_env BUILD_TMP_NAME $BUILD_TMP_NAME
github_env LATEST_PHP $LATEST_PHP
github_env LATEST_S6 $LATEST_S6
github_env OS_BASE $OS_BASE
github_env OS_VERSION $OS_VERSION
github_env PHP_VARIANT $PHP_VARIANT
github_env PHP_VERSION $PHP_VERSION
github_env S6_PATH $S6_PATH
github_env S6_VERSION $S6_VERSION
github_env SKIP_BUILD $SKIP_BUILD
github_env SKIP_SQUASH $SKIP_SQUASH
github_env SQUASH_CMD $SQUASH_CMD
github_env UPDATE_README $UPDATE_README

################################################################################
# Debug
################################################################################

if [ "$SKIP_BUILD" != "1" ]; then
    echo "🐧 Debug:"
    path_hash $BUILD_CONTEXT
    path_hash $BUILD_DOCKERFILE
    path_hash $BASE_DIR/.github/workflows/template-*
fi
