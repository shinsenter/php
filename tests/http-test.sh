#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Build the web server images, start each one and check HTTP on port 80.
# Requests send "Host: localhost", the default SERVER_NAME of the frankenphp image.
# Usage: tests/http-test.sh [php-version] [server...]
#        tests/http-test.sh clean   (delete all logs, prune all Docker data, then exit)
#   php-version  default 8.5
#   server       nginx apache f8p roadrunner (default: all)
#   --serial     build one image at a time (default: build in parallel)
# SKIP_BUILD=1 reuses images that are already built. Logs go to tests/logs.
set -u

BASE_DIR="$(git rev-parse --show-toplevel)"
LOG_DIR="$BASE_DIR/tests/logs"
# Date first so ls sorts by test day, then script name
LOG_PREFIX="$LOG_DIR/$(date +%Y%m%d)-http"

# "--serial" can be anywhere in the arguments
PARALLEL=1
args=()
for arg in "$@"; do
    if [ "$arg" = --serial ]; then PARALLEL=0; else args+=("$arg"); fi
done
set -- ${args[@]+"${args[@]}"}

# "clean" deletes all logs and prunes ALL Docker data (images, containers, volumes, networks, build cache)
if [ "${1:-}" = clean ]; then
    echo "==> Delete logs in $LOG_DIR"
    rm -rf "${LOG_DIR:?}/"*
    echo "==> Prune all Docker data"
    docker system prune -af --volumes
    docker builder prune -af
    echo "==> Clean done"
    exit 0
fi

PHP_VERSION="${1:-8.5}"
[ $# -gt 0 ] && shift
SERVERS="${*:-nginx apache f8p roadrunner}"
mkdir -p "$LOG_DIR"
echo "==> PHP $PHP_VERSION, servers: $SERVERS, SKIP_BUILD=${SKIP_BUILD:-0}, PARALLEL=$PARALLEL"
echo "==> Logs: $LOG_DIR"

WWW="$(mktemp -d)"
STATUS="$(mktemp -d)"
echo "==> Sample files in $WWW (removed on exit)"
echo '<?php echo "ok ".PHP_VERSION;' >"$WWW/index.php"
echo secret >"$WWW/.env"
trap 'rm -rf "$WWW" "$STATUS"; docker rm -f $(docker ps -aq --filter name=httptest-) >/dev/null 2>&1' EXIT

for server in $SERVERS; do
    case "$server" in
        nginx|apache|f8p|roadrunner) ;;
        *) echo "Unknown server: $server" >&2; exit 2 ;;
    esac
done

# Build phase. Each build writes its exit code to $STATUS/<server>.
build() {
    "$BASE_DIR/tests/build-test.sh" '' "with-$1" "$PHP_VERSION" >"$LOG_PREFIX-$1-$PHP_VERSION.log" 2>&1
    echo $? >"$STATUS/$1"
}

if [ "${SKIP_BUILD:-0}" != 1 ]; then
    if [ "$PARALLEL" = 1 ]; then
        # The first build also builds the shared base images, so it runs alone.
        # The other builds then reuse those images and run in parallel.
        first=1
        for server in $SERVERS; do
            echo "==> Build $server (log: $LOG_PREFIX-$server-$PHP_VERSION.log)"
            if [ "$first" = 1 ]; then
                build "$server"
                first=0
            else
                build "$server" &
            fi
        done
        echo "==> Wait for parallel builds"
        wait
    else
        for server in $SERVERS; do
            echo "==> Build $server (log: $LOG_PREFIX-$server-$PHP_VERSION.log)"
            build "$server"
        done
    fi
fi

fail=0
port=18080
for server in $SERVERS; do
    port=$((port + 1))
    case "$server" in
        nginx) image=phpfpm-nginx ;;
        apache) image=phpfpm-apache ;;
        f8p) image=frankenphp ;;
        roadrunner) image=roadrunner ;;
        *) echo "Unknown server: $server" >&2; exit 2 ;;
    esac
    tag="shinsenter/$image:local-php$PHP_VERSION"
    log="$LOG_PREFIX-$server-$PHP_VERSION.log"

    echo "==> [$server] $tag"
    if [ "${SKIP_BUILD:-0}" != 1 ] && [ "$(cat "$STATUS/$server" 2>/dev/null)" != 0 ]; then
        echo "FAIL $server: build (see $log)"
        fail=1
        continue
    fi
    # Without a build the log is new, with a build it keeps the build output
    [ "${SKIP_BUILD:-0}" = 1 ] && : >"$log"

    # RoadRunner ships its own app, the others serve the sample files
    mount="-v $WWW:/var/www/html:ro"
    [ "$server" = roadrunner ] && mount=""
    echo "    start container httptest-$server on port $port"
    docker rm -f "httptest-$server" >/dev/null 2>&1
    docker run -d --name "httptest-$server" -p "$port:80" $mount "$tag" >>"$log" 2>&1

    code() { curl -s -H 'Host: localhost' -o /dev/null -m 5 -w '%{http_code}' "http://127.0.0.1:$port$1"; }
    echo "    wait for HTTP answer (up to 80s)"
    up=0
    for _ in $(seq 1 40); do
        [ "$(code /)" != 000 ] && { up=1; break; }
        sleep 2
    done
    if [ "$up" != 1 ]; then
        echo "FAIL $server: no answer on port 80 (see $log)"
        docker logs --tail 20 "httptest-$server" >>"$log" 2>&1
        fail=1
        continue
    fi

    echo "    check /, /index.php, /.env"
    root=$(code /)
    php=$(code /index.php)
    dot=$(code /.env)
    hdr=$(curl -sI -H 'Host: localhost' -m 5 "http://127.0.0.1:$port/index.php" | tr -d '\r')
    echo "$hdr" >>"$log"
    problems=""
    [ "$root" = 200 ] || problems="$problems /=$root"
    [ "$php" = 200 ] || problems="$problems index.php=$php"
    if [ "$server" != roadrunner ]; then
        [ "$dot" -ge 400 ] 2>/dev/null || problems="$problems .env=$dot(exposed)"
        curl -s -H 'Host: localhost' -m 5 "http://127.0.0.1:$port/index.php" | grep -q '^ok ' || problems="$problems body"
        echo "$hdr" | grep -qi '^x-content-type-options: *nosniff' || problems="$problems no-nosniff"
        # The Server header may name the server but must not show a version
        ! echo "$hdr" | grep -i '^server:' | grep -q '[0-9]' || problems="$problems server-version"
    fi
    if [ -n "$problems" ]; then
        echo "FAIL $server:$problems (see $log)"
        fail=1
    else
        echo "PASS $server: / $root, index.php $php, .env $dot"
    fi
done

if [ "$fail" = 0 ]; then echo "==> All checks passed"; else echo "==> Some checks failed"; fi
exit $fail
