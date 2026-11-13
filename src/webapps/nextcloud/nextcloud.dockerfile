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
ARG BUILD_FROM_IMAGE="shinsenter/phpfpm-apache"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.5"
ARG PHP_VARIANT=""

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}php${PHP_VERSION}${PHP_VARIANT}
ARG  DEBUG

################################################################################
ADD --link ./rootfs/ /

################################################################################
# https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html
ENV DOCUMENT_ROOT=""
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
RUN env-default INITIAL_PROJECT "https://download.nextcloud.com/server/releases/latest.zip"

# https://docs.nextcloud.com/server/latest/admin_manual/installation/php_configuration.html
ENV PHP_MEMORY_LIMIT="512M"

# https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html
# The job runs only when you set ENABLE_CRONTAB=1, because cron.php fails until Nextcloud is installed
ENV CRONTAB_SETTINGS='*/5 * * * * php -f "$(app-path)"/cron.php 2>&1'

################################################################################
RUN web-cmd occ 'php "$APP_PATH"/occ'

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################
