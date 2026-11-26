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
ARG BUILD_FROM_IMAGE="shinsenter/php"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.6"
ARG PHP_VARIANT=""

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}${PHP_VERSION}-cli${PHP_VARIANT}
ARG  DEBUG

################################################################################
ADD --link ./rootfs/ /

################################################################################
# The project is mounted at /app, so the image must not create or touch a project in APP_PATH
ENV RECTOR_PROJECT_PATH="/app"
ENV DISABLE_AUTORUN_CREATING_PROJECT=1
ENV DISABLE_AUTORUN_GENERATING_INDEX=1
ENV DISABLE_AUTORUN_COPYING_SOURCE=1
ENV DISABLE_AUTORUN_COMPOSER_INSTALL=1

# The squash cleanup removes git unless this is 0, and the image needs it
ENV CLEANUP_DEV_PACKAGES=0

################################################################################
# Install Rector in APP_ROOT (latest, or RECTOR_VERSION)
ARG RECTOR_VERSION=""
RUN pkg-add git
RUN composer -d "$(app-root)" require --no-interaction --no-progress "rector/rector${RECTOR_VERSION:+:$RECTOR_VERSION}" \
    && composer clear-cache \
    && php "$(app-root)/vendor/bin/rector" --version

################################################################################
CMD ["rector-upgrade"]

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

################################################################################
