# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Enable SBOM attestations
# See: https://docs.docker.com/build/attestations/sbom/
ARG  BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG  BUILDKIT_SBOM_SCAN_STAGE=true

################################################################################

# ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-php}
# ARG  PHP_VERSION=${PHP_VERSION:-8.3}
# ARG  PHP_VARIANT=${PHP_VARIANT:-zts-alpine}

# FROM ./base-php AS php

ARG  BUILD_FROM_IMAGE=${BUILD_FROM_IMAGE:-shinsenter/php}
ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-zts-alpine}

FROM ${BUILD_FROM_IMAGE}:${PHP_VERSION}-${PHP_VARIANT}
ONBUILD RUN if has-cmd greeting; then greeting; fi

################################################################################

INCLUDE ./with-unit/unit-install
INCLUDE ./with-unit/unit-config
INCLUDE ./common/os-s6-overlay

RUN unitd --version

################################################################################

EXPOSE 80
EXPOSE 443
EXPOSE 443/udp

CMD []

################################################################################

INCLUDE ./meta

################################################################################

LABEL traefik.enable=true
