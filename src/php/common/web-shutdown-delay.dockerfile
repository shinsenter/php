################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
RUN <<'EOF'
echo 'Configure shutdown delay'
[ -z "$DEBUG" ] || set -x; set -e

env-default '# Seconds to wait before stopping the servers, so a load balancer can drain this container'
env-default SHUTDOWN_DELAY '0'

# create oneshot service that waits SHUTDOWN_DELAY seconds before the servers stop
# a service stops before the ones it depends on, so each web server adds itself as a dependency
if has-cmd s6-service; then
    s6-service shutdown-delay oneshot '#!/usr/bin/env sh
exit 0
'
fi

EOF
