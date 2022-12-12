#!/bin/bash
# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

[ ! -x "$(command -v docker)" ] && echo "Missing Docker." && exit 1

BASE_DIR="$(git rev-parse --show-toplevel)"
SRC_DIR="$BASE_DIR/src"
TEST_DIR="$BASE_DIR/tests"

################################################################################

if [ "$1" == "clean" ]; then
    shift
    rm -rf $TEST_DIR/data
    docker system prune -af
    clear
fi

################################################################################

export UID="$(id -u)"
export GID="$(id -g)"
export DOCKER_BUILDKIT=${DOCKER_BUILDKIT:-1}
export BASE_OS_IMAGE="ubuntu:latest"
export S6_VERSION="$(cat ${BASE_DIR}/S6_VERSIONS | sort -r | head -n1)"
export PHP_VERSION="${1:-8.2}"
export BUILD_PLATFORM="${2:-linux/arm64/v8}"

################################################################################

tidy() {
    local save_file="$1/Dockerfile.tidy"
    local save_path="$(dirname $save_file)"
    local image="$2"
    local replacement="\${PHP_VERSION:-$PHP_VERSION}"
    local argument="ARG  PHP_VERSION=${PHP_VERSION}"
    # mkdir -p $save_path && touch $save_file
    if [ -f $save_file ]; then
        $BASE_DIR/.bin/tidy-docker "$save_file" "$image" "${image}-tidy"
        echo -e "${argument}\n$(cat $save_file \
            | sed "s/${PHP_VERSION}/${replacement}/" \
            | sed "s/FROM *scratch/FROM scratch\n${argument}/" \
            | awk NF)" >$save_file
    else
        $BASE_DIR/.bin/tidy-docker "$image" "${image}-tidy" \
            --build-arg PHP_VERSION=$PHP_VERSION --platform=$BUILD_PLATFORM
    fi
}

################################################################################

clear
echo -e "\n🤖 Starting building S6 ${S6_VERSION} and \
php:${PHP_VERSION} images for platform ${BUILD_PLATFORM}"
mkdir -p $SRC_DIR/base/scratch

################################################################################

### Build
echo -e "\nBuilding Docker images"
echo && date \
&& $BASE_DIR/.bin/fix-attr $BASE_DIR \
&& docker-compose -f $TEST_DIR/docker-compose.scratch.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.base-s6.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.base-ubuntu.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.cli.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.fpm.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.server.yml build \
&& docker-compose -f $TEST_DIR/docker-compose.webapps.yml build \
&& echo -e "\nFinished."

CODE="$?"
[ "$CODE" -ne 0 ] && echo "Build failed." && exit $CODE

################################################################################

### Test
echo -e "\nTest running docker command"
command="composer --ansi create-project composer/installers"
docker run --rm -e PUID=$UID -e PGID=$GID shinsenter/php:${PHP_VERSION}-cli $command
docker run --rm -e PUID=$UID -e PGID=$GID shinsenter/php:${PHP_VERSION}-fpm $command

################################################################################

### Minify
echo -e "\nMinifying Docker images"
tidy $SRC_DIR/base-ubuntu "shinsenter/s6-ubuntu:latest"
for name in $(ls -1 $SRC_DIR/php/ | sort); do
    tidy $SRC_DIR/php/$name "shinsenter/php:${PHP_VERSION}-${name}"
done
for name in $(ls -1 $SRC_DIR/servers/ | sort); do
    tidy $SRC_DIR/servers/$name "shinsenter/php${name}:php${PHP_VERSION}"
done
for name in $(ls -1 $SRC_DIR/webapps/ | sort); do
    tidy $SRC_DIR/webapps/$name "shinsenter/${name}:php${PHP_VERSION}"
done

################################################################################

### Run tests
docker-compose -f $TEST_DIR/docker-compose.webapps.yml up --build --force-recreate