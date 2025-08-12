################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-roadrunner/rootfs/ /

################################################################################

RUN <<'EOF'

# create s6 services
if has-cmd s6-service; then
    s6-service roadrunner longrun '#!/usr/bin/env sh
exec app-exec with-env /usr/local/bin/rr \
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
    $ROADRUNNER_COMMAND_OPTIONS \
    $(if is-debug; then echo "-o http.pool.debug=1 -d"; fi) \
    serve
'
fi

EOF
