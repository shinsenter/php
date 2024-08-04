################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-unit/rootfs/ /

################################################################################

RUN <<'EOF'
echo 'Configure Nginx Unit'

if [ -z "$BUILD_SOURCE_IMAGE" ]; then
    exit 0
fi

# create folders
mkdir -p /etc/unit /etc/unit/sites-enabled \
    /var/lib/unit /var/log/unit /run/unit

# create s6 services
if has-cmd s6-service; then
    s6-service unit longrun '#!/usr/bin/env sh
UNIT_CONTROL_PID=${UNIT_CONTROL_PID:-/run/unit.pid}
UNIT_CONTROL_SOCKET=${UNIT_CONTROL_SOCKET:-/run/control.unit.sock}

if is-debug && has-cmd unitd-debug; then
    unitd="$(command -v unitd-debug)"
else
    unitd="$(command -v unitd)"
fi

export APP_PATH="$(app-path)"
export APP_ROOT="$(app-root)"

cd $APP_PATH
rm -rf $UNIT_CONTROL_PID
exec "$unitd" --no-daemon \
    --user ${APP_USER:-www-data} \
    --group ${APP_GROUP:-www-data} \
    --control unix:$UNIT_CONTROL_SOCKET \
    --pid $UNIT_CONTROL_PID \
    --log "$(log-path)"
'
fi

EOF
