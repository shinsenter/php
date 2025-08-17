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

ARG BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/php}
ARG BUILD_TAG_PREFIX=${BUILD_TAG_PREFIX:-}

ARG PHP_VERSION=${PHP_VERSION:-8.4}
ARG PHP_VARIANT=${PHP_VARIANT:-fpm-alpine}

FROM ${BUILD_FROM_IMAGE}:${BUILD_TAG_PREFIX}${PHP_VERSION//-rc/}-${PHP_VARIANT}
ARG  DEBUG
ONBUILD RUN hook onbuild

################################################################################

INCLUDE ./with-nginx/nginx-install
INCLUDE ./with-nginx/nginx-config
INCLUDE ./common/os-s6-overlay

RUN with-env nginx -V

RUN env-default DISABLE_ONLIVE_HOOK '0'
RUN env-default '# Other user-defined environment variables are from here'

################################################################################

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

CMD []

################################################################################

INCLUDE ./meta

################################################################################

LABEL traefik.enable=true
