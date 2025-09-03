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
ARG BUILDKIT_SBOM_SCAN_STAGE=true

################################################################################
ARG BUILD_FROM_IMAGE="shinsenter/php"
ARG BUILD_TAG_PREFIX=""

ARG PHP_VERSION="8.4"
ARG PHP_VARIANT="zts-alpine"
ARG BUILD_SOURCE_IMAGE="dunglas/frankenphp:1-php8.4-alpine"

FROM ${BUILD_SOURCE_IMAGE} AS frankenphp
FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}${PHP_VERSION//-rc/}-${PHP_VARIANT}
ARG  DEBUG

################################################################################
INCLUDE ./with-f8p/f8p-install
INCLUDE ./with-f8p/f8p-config
INCLUDE ./common/os-s6-overlay

RUN env-default DISABLE_ONLIVE_HOOK '0'
RUN env-default '# Other user-defined environment variables are from here'

################################################################################
EXPOSE 2019
EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

CMD []
HEALTHCHECK CMD curl -sf http://localhost:2019/metrics || exit 1

################################################################################
INCLUDE ./meta
ONBUILD RUN hook onbuild

ARG   BUILD_SOURCE_IMAGE
LABEL build_from="$BUILD_SOURCE_IMAGE"

################################################################################
LABEL traefik.enable=true
