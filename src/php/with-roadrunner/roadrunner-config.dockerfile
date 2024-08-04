################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-roadrunner/rootfs/ /

################################################################################

RUN <<'EOF'

# create s6 services
if has-cmd s6-service; then
    s6-service roadrunner longrun '#!/usr/bin/env sh
export APP_PATH="$(app-path)"
export APP_ROOT="$(app-root)"

cd $APP_PATH
exec /usr/local/bin/rr -w "$(app-path)" \
    -o http.address=0.0.0.0:80 \
    -o http.ssl.address=0.0.0.0:443 \
    -o http.ssl.cert=/etc/ssl/site/server.crt \
    -o http.ssl.key=/etc/ssl/site/server.key \
    -o logs.level=$(if is-debug; then echo debug; else echo info; fi) \
    -o logs.mode=$(if is-debug; then echo development; else echo production; fi) \
    -o logs.output=$(log-path) \
    -o rpc.listen=tcp://127.0.0.1:6001 \
    $ROADRUNNER_COMMAND_OPTIONS \
    $(if is-debug; then echo "-o http.pool.debug=1 -d"; fi) \
    serve
'
fi

EOF
