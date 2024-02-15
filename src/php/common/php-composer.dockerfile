################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG COMPOSER_ALLOW_SUPERUSER=1

# Add Composer to the PATH
ENV COMPOSER_HOME="/root/.composer"
ENV PATH="$COMPOSER_HOME/vendor/bin:$PATH"

################################################################################

RUN <<'EOF'
echo 'Configure Composer'
set -e

if [ ! -z "$COMPOSER_HOME" ]; then
    # Set Composer default settings
    env-default '# Environment variables for Composer'
    env-default COMPOSER_ALLOW_SUPERUSER $COMPOSER_ALLOW_SUPERUSER
    env-default COMPOSER_ALLOW_XDEBUG     '$(is-debug && echo 1 || echo 0)'
    env-default COMPOSER_FUND             '0'
    env-default COMPOSER_HTACCESS_PROTECT '1'
    env-default COMPOSER_MEMORY_LIMIT     '-1'
    env-default COMPOSER_NO_AUDIT         '1'
    env-default COMPOSER_NO_INTERACTION   '1'
    env-default COMPOSER_PROCESS_TIMEOUT  '0'

    # Install Composer
    phpaddmod @composer && composer -V

    # Make alias for Composer with env
    web-cmd root composer "$(command -v composer)"
fi
EOF
