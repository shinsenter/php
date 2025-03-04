# syntax = ghcr.io/shinsenter/dockerfile-x:v1
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Enable SBOM attestations
# See: https://docs.docker.com/build/attestations/sbom/
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true

################################################################################

ARG  OS_BASE=${OS_BASE:-alpine}
ARG  OS_VERSION=${OS_VERSION:-latest}

FROM ${OS_BASE}:${OS_VERSION}

################################################################################

INCLUDE ./common/os-base
INCLUDE ./common/os-s6-overlay
INCLUDE ./common/os-crontab

RUN echo $(source /etc/os-release && echo $NAME $VERSION) >/etc/welcome.txt

################################################################################

ENTRYPOINT /usr/local/bin/docker-php-entrypoint

################################################################################

INCLUDE ./meta

################################################################################
