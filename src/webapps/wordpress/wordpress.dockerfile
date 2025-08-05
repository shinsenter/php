# syntax = ghcr.io/shinsenter/dockerfile-x:v1
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Enable SBOM attestations
# See: https://docs.docker.com/build/attestations/sbom/
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

################################################################################

ARG BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/phpfpm-apache}
ARG BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG PHP_VERSION=${PHP_VERSION:-8.4}
ARG PHP_VARIANT=${PHP_VARIANT:-}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG
ONBUILD RUN hook onbuild

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://wordpress.org/documentation/category/installation/
ENV DOCUMENT_ROOT=""
ENV DISABLE_AUTORUN_GENERATING_INDEX=1

# recommended PHP configuration limits
ENV PHP_MAX_EXECUTION_TIME="600"
ENV PHP_MAX_INPUT_TIME="400"
ENV PHP_MAX_INPUT_VARS="1000"
ENV PHP_MEMORY_LIMIT="256M"
ENV PHP_POST_MAX_SIZE="48M"
ENV PHP_UPLOAD_MAX_FILESIZE="32M"

################################################################################

# installs wp-cli
ARG WPCLI_URL=https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
ARG WPCLI_PATH=/usr/local/bin/wp-cli

RUN <<'EOF'
echo 'Install WP-CLI'
[ -z "$DEBUG" ] || set -ex && set -e

env-default "alias wp-cli='$WPCLI_PATH --allow-root'"
env-default INITIAL_PROJECT     'manual'
env-default WP_CLI_DIR          '/.wp-cli'
env-default WP_CLI_CACHE_DIR    '$WP_CLI_DIR/cache/'
env-default WP_CLI_PACKAGES_DIR '$WP_CLI_DIR/packages/'
env-default WP_CLI_CONFIG_PATH  '$WP_CLI_DIR/config.yml'
env-default WP_DEBUG            '$(is-debug && echo 1 || echo 0)'
env-default WP_DEBUG_LOG        '$(log-path stdout)'
env-default WORDPRESS_DEBUG     '$(is-debug && echo 1 || echo 0)'

php -r "copy('$WPCLI_URL', '$WPCLI_PATH');" && chmod +xr "$WPCLI_PATH"
$WPCLI_PATH --allow-root --version

web-cmd wp "$WPCLI_PATH --allow-root"
EOF

################################################################################

INCLUDE ./meta

################################################################################
