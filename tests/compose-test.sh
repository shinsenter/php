#!/bin/sh -e
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"

if [ "$1" = "clean" ] || [ "$1" = "clear" ]; then
    docker system prune -af --volumes
    clear
    shift
fi

compose_exec() {
    docker compose -f "$BASE_DIR/tests/docker-compose.yml" "$@"
}

export IMAGE_TAG=${IMAGE_TAG:=dev-latest-alpine}
export DEBUG=${DEBUG:=1}
export ENABLE_CRONTAB=${ENABLE_CRONTAB:=1}

compose_exec pull --ignore-buildable --ignore-pull-failures
compose_exec up --remove-orphans --force-recreate --pull always -y "$@"
