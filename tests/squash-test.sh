#!/bin/sh -e
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
LOG_DIR="$BASE_DIR/tests/logs"

if [ ! -x "$BASE_DIR/build/docker-squash/docker-squash.sh" ]; then
    echo "No squash script." 1>&2
    exit 1
fi

if [ "$1" = "clean" ] || [ "$1" = "clear" ]; then
    docker system prune -af --volumes
    rm -rf "$LOG_DIR/"*
    clear
    shift
fi

. $BASE_DIR/build/helpers.sh

# docker logout ghcr.io
# . $BASE_DIR/build/.secrets
# echo $GITHUB_TOKEN | docker login ghcr.io -u shinsenter --password-stdin

platform="linux/${PLATFORM:-amd64}"
variant="${PHP_VARIANT:-}"
dockerfile="$BASE_DIR/src/${DOCKERFILE:-php/base-php.dockerfile}"
context=$(dirname $dockerfile)
s6_version=$(get_github_latest_tag "just-containers/s6-overlay" 1)

if [ ! -f "$context/meta.dockerfile" ]; then
    cp -p "$BASE_DIR/src/php/meta.dockerfile" "$context/meta.dockerfile"
fi

for version; do
    set -xe
    DEBUG= $BASE_DIR/build/docker-squash/docker-squash.sh "$dockerfile" \
        --no-cache \
        --tag "docker-php-$version-${DOCKERTAG:-$variant}:squashed" \
        --platform  "$platform" \
        --build-arg DEBUG=$DEBUG \
        --build-arg S6_VERSION=$s6_version \
        --build-arg PHP_VERSION=$version \
        --build-arg PHP_VARIANT=$variant \
        --build-arg BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-php} \
        --build-arg BUILD_TAG_PREFIX=$BUILD_TAG_PREFIX \
        2>&1 | tee "$BASE_DIR/tests/logs/squash-$version-${DOCKERTAG:-$variant}.txt" &
done

# build examples
# PLATFORM=arm64 DOCKERTAG=s6 DOCKERFILE=php/base-s6.dockerfile ./tests/squash-test.sh latest
# PLATFORM=arm64 DOCKERTAG=ubuntu-s6 DOCKERFILE=php/base-os.dockerfile ./tests/squash-test.sh latest
# PLATFORM=arm64 DOCKERTAG=cli DOCKERFILE=php/base-php.dockerfile PHP_VARIANT=cli ./tests/squash-test.sh 5.6 8.3
# PLATFORM=arm64 DOCKERTAG=fpm DOCKERFILE=php/base-php.dockerfile PHP_VARIANT=fpm ./tests/squash-test.sh 5.6 8.3
# PLATFORM=arm64 DOCKERTAG=nginx DOCKERFILE=php/with-nginx.dockerfile PHP_VARIANT=fpm-alpine ./tests/squash-test.sh 5.6 8.3
# PLATFORM=arm64 DOCKERTAG=apache DOCKERFILE=php/with-apache.dockerfile PHP_VARIANT=fpm ./tests/squash-test.sh 5.6 8.3
# PLATFORM=arm64 DOCKERTAG=f8p DOCKERFILE=php/with-f8p.dockerfile PHP_VARIANT=zts ./tests/squash-test.sh 8.3
# PLATFORM=arm64 DOCKERTAG=unit DOCKERFILE=php/with-unit.dockerfile PHP_VARIANT=zts ./tests/squash-test.sh 8.2
# PLATFORM=arm64 DOCKERTAG=roadrunner DOCKERFILE=php/with-roadrunner.dockerfile PHP_VARIANT=zts-alpine ./tests/squash-test.sh 8.0 8.3
# PLATFORM=arm64 DOCKERTAG=bedrock DOCKERFILE=webapps/bedrock/bedrock.dockerfile PHP_VARIANT= ./tests/squash-test.sh 8.3
# PLATFORM=arm64 DOCKERTAG=coolify DOCKERFILE=webapps/coolify/coolify.dockerfile PHP_VARIANT= ./tests/squash-test.sh 8.4
# PLATFORM=arm64 DOCKERTAG=hypervel DOCKERFILE=webapps/hypervel/hypervel.dockerfile PHP_VARIANT= BUILD_FROM_IMAGE=shinsenter/laravel ./tests/squash-test.sh clear 8.3 8.4

# run examples
# PLATFORM=arm64 DOCKERTAG=apache DOCKERFILE=php/with-apache.dockerfile PHP_VARIANT=fpm ./tests/squash-test.sh 5.6 8.3
# docker run --rm -p 443:443 -p 80:80 -e DEBUG=1 -e ENABLE_CRONTAB=1 -e S6_VERBOSITY=3 docker-php-5.6-apache:squashed
# docker run --rm -p 443:443 -p 80:80 -e DEBUG=1 -e ENABLE_CRONTAB=1 -e S6_VERBOSITY=3 docker-php-8.3-apache:squashed
# docker run --rm -p 443:443 -p 80:80 -e APP_USER=dev -e APP_GROUP=developers -e APP_UID=555 -e APP_GID=666 -e DEBUG=1 -e ENABLE_CRONTAB=1 -e S6_VERBOSITY=3 shinsenter/php-archives:20240731-8.3-fpm-apache
# docker run --rm -p 443:443 -p 80:80 -e APP_USER=dev -e APP_GROUP=developers -e APP_UID=555 -e APP_GID=666 -e DEBUG=1 -e ENABLE_CRONTAB=1 -e S6_VERBOSITY=3 shinsenter/php:8.3-fpm-apache
