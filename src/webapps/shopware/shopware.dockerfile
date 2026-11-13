# syntax = ghcr.io/shinsenter/dockerfile-x:v1
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Enable SBOM attestations
# See: https://docs.docker.com/build/attestations/sbom/
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true

################################################################################
ARG BUILD_FROM_IMAGE="shinsenter/phpfpm-nginx"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.5"
ARG PHP_VARIANT=""

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG

################################################################################
ADD --link ./rootfs/ /

################################################################################
# https://developer.shopware.com/docs/guides/installation/template
ENV DOCUMENT_ROOT="public"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "shopware/production"

# Shopware needs 512 MB and 30 seconds at least
ENV PHP_MEMORY_LIMIT="512M"
ENV PHP_MAX_EXECUTION_TIME="30"

# The template has no composer.lock, and Shopware itself requires mcp/sdk, which Composer blocks for a security advisory.
# Without this the install stops and the web root stays empty. Set it to 0 to keep the block, and pin the packages yourself.
RUN env-default COMPOSER_NO_BLOCKING '1'

################################################################################
RUN web-cmd console  'php "$APP_PATH"/bin/console'
RUN web-cmd shopware 'php "$APP_PATH"/bin/console'

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################
