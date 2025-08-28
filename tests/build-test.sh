#!/bin/sh -e
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
LOG_DIR="$BASE_DIR/tests/logs"
SQUASH_SCRIPT="$BASE_DIR/build/docker-squash/docker-squash.sh"

mkdir -p "$LOG_DIR"

if [ ! -x "$SQUASH_SCRIPT" ]; then
    echo "No squash script." 1>&2
    exit 1
fi

if [ "$1" = "clean" ] || [ "$1" = "clear" ]; then
    docker system prune -af --volumes
    rm -rf "$LOG_DIR/"* /tmp/helper_cache
    clear
    shift
fi

################################################################################

slugify() {
    echo "$1" | \
        tr '[:upper:]' '[:lower:]' | \
        sed -E 's/[^a-z0-9\.]+/-/g' | \
        sed -E 's/^-+|-+$//g'
}

################################################################################

set -e
eval $(BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-local-} $BASE_DIR/build/config.sh "$@" 2>/dev/null | grep -vF 'BUILD_DESC')

if [ "$SKIP_BUILD" = "1" ]; then
    echo "Skip building $BUILD_TAG."
    exit 0
fi

if [ -n "${RECURSIVE:-1}" ] && [ -n "$BUILD_FROM_IMAGE" ]; then
    deps=""
    case "$BUILD_FROM_IMAGE" in
        */php)              deps="${PHP_VARIANT/-$1/}" ;;
        */phpfpm-apache)    deps="with-apache" ;;
        */phpfpm-nginx)     deps="with-nginx" ;;
        */unit-php)         deps="with-unit" ;;
        */roadrunner)       deps="with-roadrunner" ;;
        */frankenphp)       deps="with-f8p" ;;
        */laravel)          deps="app-laravel" ;;
        */symfony)          deps="app-symfony" ;;
        */wordpress)        deps="app-wordpress" ;;
    esac

    if [ -n "$deps" ]; then
        echo "INFO: $BUILD_TAG needs $BUILD_FROM_IMAGE"
        $0 "$1" "$deps" "$3" "$4"
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to build $BUILD_FROM_IMAGE"
            exit 1
        fi
    fi
fi

{
    if [ "$SKIP_SQUASH" = "1" ]; then
        command="docker buildx build --squash -f $BUILD_DOCKERFILE $BUILD_CONTEXT"
    else
        command="$SQUASH_SCRIPT $BUILD_DOCKERFILE"
    fi

    echo ""
    echo "-------------------------------------------------"
    echo "📦 $BUILD_DATE Build: $BUILD_TAG"
    $command --tag "$BUILD_TAG" \
		--provenance=true --sbom=true \
		--attest type=sbom \
        --platform  "linux/${PLATFORM:-$(uname -m)}" \
        --build-arg DEBUG=$BUILD_DEBUG \
        --build-arg BUILD_DATE=$BUILD_DATE \
        --build-arg BUILD_FROM_IMAGE=$BUILD_FROM_IMAGE \
        --build-arg BUILD_NAME=$BUILD_NAME \
        --build-arg BUILD_SOURCE_IMAGE=$BUILD_SOURCE_IMAGE \
        --build-arg BUILD_TAG_PREFIX=$BUILD_TAG_PREFIX \
        --build-arg OS_BASE=$OS_BASE \
        --build-arg OS_VERSION=$OS_VERSION \
        --build-arg PHP_VARIANT=$PHP_VARIANT \
        --build-arg PHP_VERSION=$PHP_VERSION \
        --build-arg S6_PATH=$S6_PATH \
        --build-arg S6_VERSION=$S6_VERSION
    exit_code=$?
} 2>&1 | tee "$LOG_DIR/$(slugify "${BUILD_TAG/shinsenter\//}").txt"

if [ "$BUILD_CONTEXT" != "$BASE_DIR/src/php" ]; then
    rm -rf "$BUILD_CONTEXT/meta.dockerfile"
fi

exit $exit_code

# build examples
# PLATFORM=amd64 ./tests/build-test.sh '' 'base-os'
# PLATFORM=amd64 ./tests/build-test.sh 'alpine' 'base-os'

# PLATFORM=amd64 ./tests/build-test.sh '' 'with-nginx' 8.4
# PLATFORM=amd64 ./tests/build-test.sh 'alpine' 'with-nginx' 8.4

# PLATFORM=amd64 ./tests/build-test.sh '' 'app-laravel' 8.4
# PLATFORM=amd64 ./tests/build-test.sh 'alpine' 'app-laravel' 8.4
