# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM shinsenter/phpfpm-nginx:php${PHP_VERSION}${PHP_VARIANT}

################################################################################

ADD --link ./rootfs/ /

################################################################################

# https://hyperf.wiki/3.1/#/en/quick-start/install
ENV DOCUMENT_ROOT=""
ENV INITIAL_PROJECT="hyperf/hyperf-skeleton"
ENV DISABLE_AUTORUN_GENERATING_INDEX=1

################################################################################

RUN <<'EOF'
set -e

phpaddmod protobuf swoole

web-cmd hyperf 'php $(app-path)/bin/hyperf.php'
env-default PHP_SWOOLE_USE_SHORTNAME 'off'

if has-cmd s6-service; then
    s6-service nginx depends hyperf
    s6-service hyperf longrun '#!/usr/bin/env sh
export APP_PATH="$(app-path)"
export APP_ROOT="$(app-root)"

cd $APP_PATH
exec php $APP_PATH/bin/hyperf.php start
'
fi

EOF

################################################################################

INCLUDE ./meta

################################################################################
