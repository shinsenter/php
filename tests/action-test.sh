#!/bin/sh -e
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
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

export DOCKER_HOST=$(docker context inspect --format '{{.Endpoints.docker.Host}}')

set -xe
act --bind --network host --use-gitignore=false --reuse=false --rm=true \
    --workflows "$BASE_DIR/.github/workflows/${ACTION_WORKFLOW:-02-servers.yml}" \
    --platform "ubuntu-22.04=catthehacker/ubuntu:act-22.04" \
    --secret-file "$BASE_DIR/build/.secrets" \
    --env "TESTING=1" \
    --env "SKIP_SQUASH=${SKIP_SQUASH:-1}" \
    --env "DUMMY=${DUMMY:-}" \
    --env "DEBUG=${DEBUG:-}" \
    --env "PUBLISH_TO_GHCR=${PUBLISH_TO_GHCR:-}" \
    "$@"

# Exmaples
# ACTION_WORKFLOW=00-s6-overlay.yml ./tests/action-test.sh --job debian-s6
# ACTION_WORKFLOW=01-php.yml ./tests/action-test.sh --job php --matrix "app:fpm"
# ACTION_WORKFLOW=02-servers.yml ./tests/action-test.sh --job php-servers --matrix "app:with-apache"
# ACTION_WORKFLOW=03-apps.yml ./tests/action-test.sh --job php-apps --matrix "app:app-laravel"
