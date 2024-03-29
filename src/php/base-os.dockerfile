# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  OS_BASE=${OS_BASE:-alpine}
ARG  OS_VERSION=${OS_VERSION:-latest}

FROM ${OS_BASE}:${OS_VERSION}

################################################################################

INCLUDE ./common/base-meta
INCLUDE ./common/os-base
INCLUDE ./common/os-s6-overlay
INCLUDE ./common/os-crontab

################################################################################

ENTRYPOINT /usr/local/bin/docker-php-entrypoint
