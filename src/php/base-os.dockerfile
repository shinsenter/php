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
ARG OS_BASE="alpine"
ARG OS_VERSION="latest"

FROM ${OS_BASE}:${OS_VERSION}
ARG  DEBUG

################################################################################
INCLUDE ./common/os-common
INCLUDE ./common/os-s6-overlay
INCLUDE ./common/os-crontab

RUN echo $(source /etc/os-release && echo $NAME $VERSION) >/etc/welcome.txt
RUN env-default '# Other user-defined environment variables are from here'

################################################################################
EXPOSE 22

ENTRYPOINT /usr/local/bin/docker-php-entrypoint

################################################################################
INCLUDE ./meta

################################################################################
