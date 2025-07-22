################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# install crontab
RUN <<'EOF'
echo 'Configure base crontab'
[ -z "$DEBUG" ] || set -ex && set -e

env-default '# Environment variables for crontab'
env-default CRONTAB_SHELL   '/bin/sh'
env-default CRONTAB_MAILTO  '$APP_ADMIN'
env-default CRONTAB_OPTIONS ''

if ! has-cmd crond; then
    pkg-add cron
    ln -nsf $(command -v cron) /usr/sbin/crond
fi

if has-cmd s6-service; then
    s6-service crontab longrun '#!/usr/bin/env sh
if is-true $ENABLE_CRONTAB; then
    cd "$(app-path)"
    exec 2>&1
    exec crond -f $CRONTAB_OPTIONS
else
    exec s6-svc -Od .
fi
'
fi

EOF

################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
################################################################################
