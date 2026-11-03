################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
ADD --link ./with-roadrunner/rootfs/ /

################################################################################
RUN <<'EOF'
echo 'Configure RoadRunner'
[ -z "$DEBUG" ] || set -x; set -e

# port of the health checks (not exposed) and the URL that the startup check uses
env-default HEALTH_PORT '2020'
env-default HEALTH_CHECK_URL 'http://127.0.0.1:${HEALTH_PORT}/health?plugin=http'

# the health URL answers 503 while no worker runs, and in debug mode that lasts until the first request,
# so the onlive hook accepts any answer in debug mode and waits for a ready worker otherwise
env-default ONLIVE_WAIT_CODES "\$(is-debug && echo '^[1-5][0-9]{2}\$')"

# create s6 services
if has-cmd s6-service; then
    s6-service roadrunner longrun '#!/usr/bin/env bash
exec in-app /usr/local/bin/rr \
    -w "$APP_PATH" \
    -o server.user="$APP_USER" \
    -o server.group="$APP_GROUP" \
    -o http.address=0.0.0.0:80 \
    -o http.ssl.address=0.0.0.0:443 \
    -o http.ssl.cert=/etc/ssl/site/server.crt \
    -o http.ssl.key=/etc/ssl/site/server.key \
    -o logs.level=$(if is-debug; then echo debug; else echo error; fi) \
    -o logs.mode=$(if is-debug; then echo development; else echo production; fi) \
    -o logs.output=$(log-path stdout) \
    -o rpc.listen=tcp://127.0.0.1:6001 \
    -o status.address=0.0.0.0:${HEALTH_PORT:-2020} \
    $ROADRUNNER_COMMAND_OPTIONS \
    $(if is-debug; then echo "-o http.pool.debug=1 -d"; fi) \
    serve
'
    s6-service shutdown-delay requires roadrunner
fi

EOF
