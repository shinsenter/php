################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-f8p/rootfs/ /

################################################################################

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV GODEBUG="cgocheck=0"
ENV XDG_CONFIG_HOME="/config"
ENV XDG_DATA_HOME="/data"

################################################################################

RUN <<'EOF'
echo 'Configure FrankenPHP'

env-default '# Environment variables for Caddy'
env-default CADDY_GLOBAL_OPTIONS            ''
env-default CADDY_EXTRA_CONFIG              ''
env-default CADDY_SERVER_EXTRA_DIRECTIVES   ''

if [ -f /etc/caddy/Caddyfile ]; then
    frankenphp fmt --overwrite /etc/caddy/Caddyfile
fi

# create s6 services
if has-cmd s6-service; then
    s6-service frankenphp longrun '#!/usr/bin/env sh
export APP_PATH="$(app-path)"
export APP_ROOT="$(app-root)"
if [ -f /etc/caddy/envvars ]; then source /etc/caddy/envvars; fi

cd $APP_PATH
exec frankenphp run --config /etc/caddy/Caddyfile --adapter caddyfile
'
fi

EOF
