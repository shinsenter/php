#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Docker test for scaling: Traefik in front of several replicas of one web image.
#
# Usage: tests/scaling-test.sh <image> [replicas]
#   tests/scaling-test.sh shinsenter/phpfpm-nginx:local-php8.4
#   KEEP=1 tests/scaling-test.sh shinsenter/phpfpm-apache:local-php8.4 4
#
# It checks the container health (the healthcheck of the compose file, which reads HEALTH_CHECK_URL), load balancing,
# the client address and HTTPS behind the proxy, and that a running request survives when one replica is stopped.
# The variant comes from the image name (SCALING_VARIANT overrides it): nginx, apache, frankenphp or roadrunner.
# Health is on its own port (HEALTH_PORT, not exposed), so it is probed inside a replica with docker exec.
# RoadRunner runs its own worker app, so the app checks are skipped for it.
# Needs Docker and a built image.
# It does not build the image under test, only the small test app on top of it.
# KEEP=1 leaves the stack running, SCALING_PORT changes the host port (default 8180).

source "$(dirname "$0")/run.sh"
NAME="scaling-test"

IMAGE="${1:?Usage: $0 <image> [replicas]}"
REPLICAS="${2:-3}"
PORT="${SCALING_PORT:-8180}"
URL="http://127.0.0.1:$PORT"
COMPOSE=(docker compose -p scaling-test -f "$BASE_DIR/tests/docker-compose.scaling.yml")
case "${SCALING_VARIANT:-$IMAGE}" in
    *roadrunner*) READY_BODY="";     APP=0 ;;
    *frankenphp*) READY_BODY="ok";   APP=1 ;;
    *)            READY_BODY="pong"; APP=1 ;;
esac
export SCALING_IMAGE="$IMAGE" SCALING_PORT="$PORT"
# the plain Dockerfile keeps the worker app of the image, because RoadRunner cannot serve plain PHP files
[ "$APP" = 1 ] || export SCALING_DOCKERFILE=Dockerfile.plain

TMP="$(mktemp -d)"
cleanup() {
    rm -rf "$TMP"
    [ -n "$KEEP" ] || "${COMPOSE[@]}" down -v --remove-orphans >/dev/null 2>&1
}
trap cleanup EXIT

# running replicas of the app service, optionally filtered by health
replicas() {
    docker ps -q --filter label=com.docker.compose.project=scaling-test \
        --filter label=com.docker.compose.service=app "$@"
}

json_field() { sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p"; }

"${COMPOSE[@]}" up -d --build --scale app="$REPLICAS" || { echo "FAIL: compose up" >&2; exit 1; }

# wait until every replica is healthy and Traefik has picked them up
for _ in $(seq 1 60); do
    [ "$(replicas --filter health=healthy | wc -l)" -ge "$REPLICAS" ] && break
    sleep 2
done
sleep 3
check_eq "healthy replicas" "$REPLICAS" "$(replicas --filter health=healthy | wc -l | tr -d ' ')"

# health endpoints on their own port, called on the address of a replica like an orchestrator does
first="$(replicas | head -n 1)"
code="$(docker exec "$first" with-env sh -c 'curl -s -o /dev/null -w "%{http_code}" "$HEALTH_CHECK_URL"')"
check_eq "health endpoint status" "200" "$code"
if [ -n "$READY_BODY" ]; then
    body="$(docker exec -e SUFFIX=/readyz "$first" with-env sh -c 'curl -s "${HEALTH_CHECK_URL%/healthz}$SUFFIX"' | tr -d '\r\n')"
    check_eq "/readyz body" "$READY_BODY" "$body"
fi

if [ "$APP" = 1 ]; then
    # load balancing: 30 requests must reach more than one replica
    hosts="$(for _ in $(seq 1 30); do curl -s "$URL/" | json_field host; done | sort -u | wc -l | tr -d ' ')"
    check "requests reach more than one replica (got $hosts)" test "$hosts" -gt 1

    # client address and HTTPS behind the proxy
    body="$(curl -s -H 'X-Forwarded-Proto: https' -H 'X-Forwarded-For: 203.0.113.9' "$URL/")"
    check_eq "REMOTE_ADDR from X-Forwarded-For" "203.0.113.9" "$(json_field remote_addr <<<"$body")"
    check_eq "HTTPS from X-Forwarded-Proto" "on" "$(json_field https <<<"$body")"
    check_eq "REQUEST_SCHEME from X-Forwarded-Proto" "https" "$(json_field scheme <<<"$body")"
    body="$(curl -s "$URL/")"
    check_eq "no HTTPS flag for plain HTTP" "" "$(json_field https <<<"$body")"
fi

# stop one replica while requests are running: they must finish
victim="$(replicas | tail -n 1)"
if [ "$APP" = 1 ]; then
    for i in $(seq 1 $((REPLICAS * 2))); do
        curl -s -o /dev/null -w '%{http_code}' -m 30 "$URL/slow.php?s=6" >"$TMP/$i" &
    done
    sleep 1
fi
start=$(date +%s)
docker stop -t 30 "$victim" >/dev/null
elapsed=$(($(date +%s) - start))
wait
if [ "$APP" = 1 ]; then
    ok="$(cat "$TMP"/* | grep -c '^200$')"
    check_eq "requests that finished with 200 during the stop" "$((REPLICAS * 2))" "$ok"
fi
check "stop took less than 28s (took ${elapsed}s)" test "$elapsed" -lt 28

finish
