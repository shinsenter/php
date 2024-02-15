#!/bin/sh -e
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"

if [ ! -x "$(command -v docker)" ]; then
    echo "docker is not installed. See https://docs.docker.com/get-docker/" 1>&2
    exit 1
fi

if [ ! -x "$(command -v act)" ]; then
    echo "act is not installed. See https://github.com/nektos/act" 1>&2
    exit 1
fi

if [ "$1" = "clean" ] || [ "$1" = "clear" ]; then
    docker system prune -af
    docker volume prune -f
    rm -rf /.cache/act
    clear
    shift
fi

################################################################################

# export DOCKER_HOST=$(docker context inspect --format '{{.Endpoints.docker.Host}}')

set -xe
act --bind --network host --use-gitignore=false --reuse=false --rm=true \
    --workflows "$BASE_DIR/.github/workflows/${ACTION_WORKFLOW:-php-main-images.yml}" \
    --platform "ubuntu-latest=catthehacker/ubuntu:act-22.04" \
    --secret-file "$BASE_DIR/build/.secrets" \
    --env "TESTING=1" \
    --env "SKIP_SQUASH=${SKIP_SQUASH:-1}" \
    --env "DUMMY=${DUMMY:-}" \
    --env "DEBUG=${DEBUG:-}" \
    --env "PUBLISH_TO_GHCR=${PUBLISH_TO_GHCR:-}" \
    "$@"
