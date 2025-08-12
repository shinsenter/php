################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-unit/rootfs/ /

################################################################################

RUN <<'EOF'
echo 'Configure Nginx Unit'

if [ -z "$BUILD_SOURCE_IMAGE" ]; then
    exit 0
fi

# create directories
mkdir -p /etc/unit /etc/unit/sites-enabled \
    /var/lib/unit /var/log/unit /run/unit

# create s6 services
if has-cmd s6-service; then
    s6-service unit longrun '#!/usr/bin/env sh
unit_pid="${UNIT_CONTROL_PID:-/run/unit.pid}"
unit_socket="${UNIT_CONTROL_SOCKET:-/run/control.unit.sock}"

if is-debug && has-cmd unitd-debug; then
    unitd="$(command -v unitd-debug)"
else
    unitd="$(command -v unitd)"
fi

rm -rf "$unit_pid" || true
exec app-exec with-env "$unitd" --no-daemon \
    --user "${APP_USER:-www-data}" \
    --group "${APP_GROUP:-www-data}" \
    --control unix:"$unit_socket" \
    --pid "$unit_pid" \
    --log "$(log-path stdout)"
'
fi

EOF
