#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Docker test for issue #442: the UID/GID change at startup must not touch
# mounted files such as /var/run/docker.sock.
#
# Usage: tests/ownership-test.sh <image> [app-uid]
#   tests/ownership-test.sh shinsenter/phpfpm-nginx:local-php8.5-alpine
#   DOCKER_PLATFORM=linux/amd64 tests/ownership-test.sh shinsenter/php:dev-8.3-fpm
#
# It starts the real entrypoint with an APP_GID that another group already
# uses, so `groupmod` fails as in the issue. Needs Docker and a privileged
# container (bind mounts). It does not build anything.

source "$(dirname "$0")/lib.sh"

IMAGE="${1:?Usage: $0 <image> [app-uid]}"
APP_UID="${2:-1001}"
RUN=(docker run --rm)
[ -n "$DOCKER_PLATFORM" ] && RUN+=(--platform "$DOCKER_PLATFORM")

# IDs of www-data in the image, and a GID that belongs to another group
WWW_UID="$("${RUN[@]}" --entrypoint id "$IMAGE" -u www-data)" || exit 1
WWW_GID="$("${RUN[@]}" --entrypoint id "$IMAGE" -g www-data)" || exit 1
CONFLICT_GID="$("${RUN[@]}" --entrypoint sh "$IMAGE" -c \
    "getent group | awk -F: -v w=$WWW_GID '\$3 > 0 && \$3 < 1000 && \$3 != w {print \$3; exit}'")"
[ -n "$CONFLICT_GID" ] || { echo "No other group found in $IMAGE" >&2; exit 1; }
echo "Image $IMAGE: www-data is $WWW_UID:$WWW_GID, APP_UID=$APP_UID, APP_GID=$CONFLICT_GID (already in use)"

# Runs as root before the entrypoint. Files that the container can reach only
# through their mount point stand for a file on the host. Owned by www-data, so
# an unsafe migration would match them.
read -r -d '' SETUP <<'EOF'
set -e
mkdir -p /host /srv/data /opt
touch /host/file && chown "$WWW_UID:$WWW_GID" /host/file
touch /opt/mounted-file && mount --bind /host/file /opt/mounted-file
/usr/local/bin/php -r '$s = stream_socket_server("unix:///host/sock", $e, $m); sleep(120);' &
sleep 1; chown "$WWW_UID:$WWW_GID" /host/sock
touch /opt/mounted-sock && mount --bind /host/sock /opt/mounted-sock
touch /host/docker && chown "$WWW_UID:$WWW_GID" /host/docker
touch /run/docker.sock && mount --bind /host/docker /run/docker.sock
rm -f /host/file /host/sock /host/docker
echo data >/srv/data/plain.txt && chown "$WWW_UID:$WWW_GID" /srv/data/plain.txt
mkdir -p /run/app-state && chown "$WWW_UID:$WWW_GID" /run/app-state
exec docker-php-entrypoint sh -c '
    for path in /opt/mounted-file /opt/mounted-sock /run/docker.sock /srv/data/plain.txt /run/app-state; do
        echo "RESULT $path $(stat -c "%u:%g" "$path")"
    done
    echo "RESULT www-data-gid $(id -g www-data)"'
EOF

OUTPUT="$("${RUN[@]}" --privileged \
    -e APP_UID="$APP_UID" -e APP_GID="$CONFLICT_GID" \
    -e WWW_UID="$WWW_UID" -e WWW_GID="$WWW_GID" \
    --entrypoint sh "$IMAGE" -c "$SETUP" 2>&1)"

result() { echo "$OUTPUT" | awk -v k="$1" '$1 == "RESULT" && $2 == k {print $3}'; }

echo "$OUTPUT" | grep -E 'groupmod|Cannot change|Changed www-data|Updating file ownership'

check_eq "mounted file keeps its owner" "$WWW_UID:$WWW_GID" "$(result /opt/mounted-file)"
check_eq "mounted socket keeps its owner" "$WWW_UID:$WWW_GID" "$(result /opt/mounted-sock)"
check_eq "file mounted at /run/docker.sock keeps its owner" "$WWW_UID:$WWW_GID" "$(result /run/docker.sock)"
check_eq "www-data keeps its primary group" "$WWW_GID" "$(result www-data-gid)"
check_eq "plain file moves to the new UID" "$APP_UID" "$(result /srv/data/plain.txt | cut -d: -f1)"
check_eq "file under /run moves to the new UID" "$APP_UID" "$(result /run/app-state | cut -d: -f1)"

finish
