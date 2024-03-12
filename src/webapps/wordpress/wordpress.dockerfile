# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
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

# https://wordpress.org/documentation/category/installation/
ENV DOCUMENT_ROOT=""
ENV DISABLE_GENERATING_INDEX=1

################################################################################

# installs wp-cli
ARG WPCLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
ARG WPCONFIG_URL=https://raw.githubusercontent.com/docker-library/wordpress/master/wp-config-docker.php

RUN <<'EOF'
echo 'Install WP-CLI'

set -e

env-default '# Environment variables for WP-Cli'
env-default WP_CLI_CACHE_DIR '/home/${APP_USER}/.wp-cli/cache/'
env-default WP_CLI_CONFIG_PATH '/home/${APP_USER}/.wp-cli/config.yml'
env-default WP_CLI_PACKAGES_DIR '/home/${APP_USER}/.wp-cli/packages/'

php -r "copy('$WPCLI_URL', '/usr/bin/wp-cli');" && chmod +xr /usr/bin/wp-cli
php -r "copy('$WPCONFIG_URL', '/etc/wp-config.php');"
web-cmd wp '/usr/bin/wp-cli --allow-root --path="$(app-path)"'
EOF
