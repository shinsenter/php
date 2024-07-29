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
cd "$(app-path)"
exec /usr/local/bin/rr -w "$(app-path)" \
    -o rpc.listen=tcp://127.0.0.1:6001 \
    -o http.address=0.0.0.0:80 \
    -o http.ssl.address=0.0.0.0:443 \
    -o http.ssl.cert=/etc/ssl/site/server.crt \
    -o http.ssl.key=/etc/ssl/site/server.key \
    -o http.pool.debug=$(is-debug && echo 1 || echo 0) \
    $(if is-debug; then echo -d; fi) \
    $ROADRUNNER_COMMAND_OPTIONS \
    serve
'
fi

EOF
