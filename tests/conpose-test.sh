#!/bin/sh -e
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
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

export PHP_VERSION=${PHP_VERSION:=latest}
export PREFIX=${PREFIX:=dev-}
export SUFFIX=${SUFFIX:=-alpine}
export DEBUG=${DEBUG:=1}

compose_exec down --remove-orphans --volumes --timeout 10
compose_exec pull --ignore-buildable --ignore-pull-failures
compose_exec up --pull always "$@"
