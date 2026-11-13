#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Start the images in tests/docker-compose.yml in batches, wait until each
# container answers on port 80, record the HTTP status of / and stop the batch.
# Usage: tests/compose-test.sh [-n N] [-v PHP_VERSION] [-o alpine|debian] [-t SECONDS] [-s] [keyword...]
#   -n N           containers per batch (default 4)
#   -v PHP_VERSION default latest
#   -o OS          alpine (default) or debian
#   -t SECONDS     wait for init per container (default 120)
#   -s             strict: follow redirects and pass only on HTTP 2xx (default: any HTTP answer)
#   keyword        run only services whose name contains a keyword, "with-" is ignored
#                  (default: all except cli and fpm)
# IMAGE_TAG overrides the tag built from -v and -o: dev-php<version>[-alpine].
# Results go to tests/logs/<date>-compose-<tag>.csv.
# The csv has the columns service, status, result and header (all response header lines
# on one line, or ERROR when the container never answered).
# A container passes when it answers HTTP, or with -s when the final answer is 2xx.
# With -s the check keeps polling until 2xx or the wait ends, so a slow installer can still pass.
# For status 400 and above the response
# header and body go to tests/logs/<date>-compose-<tag>-<service>.http.
set -u

BASE_DIR="$(git rev-parse --show-toplevel)"
LOG_DIR="$BASE_DIR/tests/logs"
# Date first so ls sorts by test day, then script name
LOG_PREFIX="$LOG_DIR/$(date +%Y%m%d)-compose"
N=4
PHP_VERSION=latest
OS=alpine
WAIT=120
STRICT=0
FAIL=0

usage() {
    # Print the header comment above (lines 9-22) as help text
    sed -n '9,22p' "$0" | cut -c3-
    exit 2
}

# Fixed project name keeps "down" away from containers of other projects
compose() {
    docker compose -p php-docker-testing -f "$BASE_DIR/tests/docker-compose.yml" "$@"
}

parse_args() {
    while getopts n:v:o:t:s opt; do
        case "$opt" in
            n) N="$OPTARG" ;;
            v) PHP_VERSION="$OPTARG" ;;
            o) OS="$OPTARG" ;;
            t) WAIT="$OPTARG" ;;
            s) STRICT=1 ;;
            *) usage ;;
        esac
    done
    shift $((OPTIND - 1))
    KEYWORDS="$*"

    case "$N$WAIT" in *[!0-9]*|'') echo "-n and -t need a number" >&2; exit 2 ;; esac
    [ "$N" -ge 1 ] || { echo "-n must be at least 1" >&2; exit 2; }
    case "$OS" in
        alpine) SUFFIX=-alpine ;;
        debian) SUFFIX= ;;
        *) echo "-o must be alpine or debian" >&2; exit 2 ;;
    esac
}

# Fill SERVICES with the compose services that match the keywords
select_services() {
    SERVICES=""
    for name in $(compose config --services | grep -vx -e cli -e fpm); do
        keep=0
        [ -z "$KEYWORDS" ] && keep=1
        for key in $KEYWORDS; do
            case "$name" in *"${key#with-}"*) keep=1 ;; esac
        done
        [ "$keep" = 1 ] && SERVICES="$SERVICES $name"
    done
    [ -n "$SERVICES" ] || { echo "No service to test" >&2; exit 2; }
}

# Poll a service until it answers HTTP. Sets CODE (000 when it never answers).
# The last response goes to $1.h (header) and $1.b (body).
wait_http() {
    svc="$1"
    out="$2"
    CODE=000
    port=$(compose port "$svc" 80 2>/dev/null | sed 's/.*://')
    [ -n "$port" ] || return 0
    # Strict mode judges the page after the redirects, such as an installer page
    FOLLOW=; [ "$STRICT" = 1 ] && FOLLOW=-L
    waited=0
    while [ "$waited" -lt "$WAIT" ]; do
        CODE=$(curl -s $FOLLOW -D "$out.h" -o "$out.b" -m 5 -w '%{http_code}' "http://127.0.0.1:$port/")
        if [ "$STRICT" = 1 ]; then
            case "$CODE" in 2??) return 0 ;; esac
        else
            [ "$CODE" != 000 ] && return 0
        fi
        sleep 2
        waited=$((waited + 2))
    done
}

# Print the response header file as one quoted csv field, lines joined by " | "
# A Set-Cookie value longer than 20 characters is cut, so session tokens do not land in the log.
csv_header() {
    tr -d '\r' <"$1" | awk '
        NF {
            if (tolower($0) ~ /^set-cookie:/) {
                i = index($0, "=")
                rest = substr($0, i + 1)
                j = index(rest, ";")
                val = j ? substr(rest, 1, j - 1) : rest
                if (length(val) > 20) $0 = substr($0, 1, i) substr(val, 1, 20) "..." (j ? substr(rest, j) : "")
            }
            out = out sep $0
            sep = " | "
        }
        END { gsub(/"/, "\"\"", out); printf "\"%s\"", out }'
}

# Test one service and append its line to the result file
check_service() {
    svc="$1"
    prefix="$LOG_PREFIX-$IMAGE_TAG-$svc"

    wait_http "$svc" "$prefix"
    if [ "$CODE" = 000 ]; then
        res=FAIL
        header=ERROR
        FAIL=1
        # No answer, so the container log is the only clue
        compose logs --tail 20 "$svc" >"$prefix.log" 2>&1
    else
        res=PASS
        # Strict mode fails an answer that is not 2xx, and keeps the response for review
        case "$STRICT$CODE" in 1[!2]*) res=FAIL; FAIL=1 ;; esac
        header=$(csv_header "$prefix.h")
        # An error page still counts as an answer, keep it for review
        if [ "$CODE" -ge 400 ]; then
            { cat "$prefix.h"; echo; head -c 4000 "$prefix.b"; } >"$prefix.http"
        fi
    fi
    rm -f "$prefix.h" "$prefix.b"

    printf '%s,%s,%s,%s\n' "$svc" "$CODE" "$res" "$header" >>"$RESULT"
    echo "    $res $svc: $CODE"
}

# Start the services in $BATCH, test each one, then remove them to free ports and memory
run_batch() {
    echo "==> Batch:$BATCH"
    # A pull failure is not fatal: the missing image shows up as FAIL below
    compose pull --ignore-pull-failures $BATCH >"$LOG_PREFIX-$IMAGE_TAG-pull.log" 2>&1
    compose up -d --force-recreate --no-deps $BATCH >"$LOG_PREFIX-$IMAGE_TAG-up.log" 2>&1
    for svc in $BATCH; do
        check_service "$svc"
    done
    compose rm -sf -v $BATCH >/dev/null 2>&1
}

parse_args "$@"
# Published tags are dev-php8.5[-alpine], but "latest" has no "php" part
case "$PHP_VERSION" in latest) TAG_VERSION=latest ;; *) TAG_VERSION="php$PHP_VERSION" ;; esac
export IMAGE_TAG="${IMAGE_TAG:-dev-$TAG_VERSION$SUFFIX}"
export DEBUG="${DEBUG:-1}"
export ENABLE_CRONTAB="${ENABLE_CRONTAB:-1}"

docker info >/dev/null 2>&1 || { echo "Docker daemon is not running" >&2; exit 2; }
select_services

mkdir -p "$LOG_DIR"
RESULT="$LOG_PREFIX-$IMAGE_TAG.csv"
echo 'service,status,result,header' >"$RESULT"
echo "==> Tag $IMAGE_TAG, $N containers per batch, services:$SERVICES"
echo "==> Result: $RESULT"

# Stop everything on exit, also after Ctrl-C
trap 'compose down --remove-orphans >/dev/null 2>&1' EXIT

# Cut the service list into batches of N
BATCH=""
count=0
for svc in $SERVICES; do
    BATCH="$BATCH $svc"
    count=$((count + 1))
    if [ "$count" -ge "$N" ]; then
        run_batch
        BATCH=""
        count=0
    fi
done
[ -n "$BATCH" ] && run_batch

echo "==> $(grep -c ',PASS,' "$RESULT") passed, $(grep -c ',FAIL,' "$RESULT") failed (see $RESULT)"
exit $FAIL
