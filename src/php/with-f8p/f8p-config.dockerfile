################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
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
env-default CADDY_GLOBAL_OPTIONS            'auto_https disable_redirects'
env-default CADDY_EXTRA_CONFIG              ''
env-default CADDY_SERVER_EXTRA_DIRECTIVES   ''
env-default CADDY_LOG_LEVEL                 '$(is-debug && echo DEBUG || echo ERROR)'

if [ -f /etc/caddy/Caddyfile ]; then
    frankenphp fmt --overwrite /etc/caddy/Caddyfile
fi

# create s6 services
if has-cmd s6-service; then
    s6-service frankenphp longrun '#!/usr/bin/env sh
if [ -f /etc/caddy/envvars ]; then source /etc/caddy/envvars; fi
exec in-app frankenphp run \
    --config /etc/caddy/Caddyfile \
    --adapter caddyfile
'
fi

EOF
