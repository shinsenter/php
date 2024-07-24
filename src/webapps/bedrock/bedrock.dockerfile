# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-apache}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:php${PHP_VERSION}${PHP_VARIANT}

################################################################################

INCLUDE ./meta

ADD --link ./rootfs/ /

################################################################################

# https://bedrock.org/documentation/category/installation/
ENV DOCUMENT_ROOT="/web"
ENV INITIAL_PROJECT="roots/bedrock"
ENV DISABLE_GENERATING_INDEX=1

################################################################################

# installs wp-cli
ARG WPCLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
ARG WPCLI_PATH=/usr/local/bin/wp-cli

RUN <<'EOF'
echo 'Install WP-CLI'

set -e

web-mkdir "/.wp-cli"

env-default '# Environment variables for WP-Cli'
env-default WP_CLI_DIR          '/.wp-cli'
env-default WP_CLI_CACHE_DIR    '$WP_CLI_DIR/cache/'
env-default WP_CLI_PACKAGES_DIR '$WP_CLI_DIR/packages/'
env-default WP_CLI_CONFIG_PATH  '$WP_CLI_DIR/config.yml'
env-default WP_DEBUG            '$(is-debug && echo 1 || echo 0)'
env-default WP_DEBUG_LOG        '$(log-path)'

php -r "copy('$WPCLI_URL', '$WPCLI_PATH');" && chmod +xr $WPCLI_PATH
web-cmd wp "$WPCLI_PATH --allow-root --path=\"\$(app-path)/web/wp\""
wp package install aaemnnosttv/wp-cli-dotenv-command:^2.0
EOF
