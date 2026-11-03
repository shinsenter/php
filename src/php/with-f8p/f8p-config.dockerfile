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
[ -z "$DEBUG" ] || set -x; set -e

env-default '# Environment variables for FrankenPHP'
env-default CADDY_GLOBAL_OPTIONS            'auto_https disable_redirects'
env-default CADDY_EXTRA_CONFIG              ''
env-default CADDY_SERVER_EXTRA_DIRECTIVES   ''
env-default CADDY_LOG_LEVEL                 '$(is-debug && echo DEBUG || echo ERROR)'
env-default FRANKENPHP_CONFIG               ''

# port of the health checks (not exposed) and the URL that the startup check uses
env-default HEALTH_PORT                     '2020'
env-default HEALTH_CHECK_URL                'http://127.0.0.1:${HEALTH_PORT}/healthz'

if [ -f /etc/caddy/Caddyfile ]; then
    # Without "--overwrite", fmt prints the result but exits non-zero when the input changes.
    # An empty result means a real error, so the build still stops.
    frankenphp fmt /etc/caddy/Caddyfile >/tmp/Caddyfile.fmt || [ -s /tmp/Caddyfile.fmt ]
    cat /tmp/Caddyfile.fmt >/etc/caddy/Caddyfile
    rm -f /tmp/Caddyfile.fmt
fi

# create s6 services
if has-cmd s6-service; then
    s6-service frankenphp longrun '#!/usr/bin/env bash
if [ -f /etc/caddy/envvars ]; then source /etc/caddy/envvars; fi
exec in-app frankenphp run \
    --config /etc/caddy/Caddyfile \
    --adapter caddyfile
'
    s6-service shutdown-delay requires frankenphp
fi

EOF
