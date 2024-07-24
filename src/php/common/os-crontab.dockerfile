################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# install crontab
RUN <<'EOF'
echo 'Configure base crontab'
set -e

if ! has-cmd crond; then
    pkg-add cron
    ln -nsf $(command -v cron) /usr/sbin/crond
fi

if has-cmd s6-service; then
    s6-service crontab longrun '#!/usr/bin/env sh
if is-true $ENABLE_CRONTAB; then
    exec crond -f $CRONTAB_OPTIONS
else
    exec s6-svc -Od .
fi
'
else
    sed -i 's|^exec |\nif is-true $ENABLE_CRONTAB; then with-env crond $CRONTAB_OPTIONS; fi\n\nexec |' $DOCKER_ENTRYPOINT
fi
EOF
