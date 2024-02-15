# syntax = devthefuture/dockerfile-x
################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG  PHP_VERSION=${PHP_VERSION:-8.3}
ARG  PHP_VARIANT=${PHP_VARIANT:-}

FROM shinsenter/phpfpm-nginx:php${PHP_VERSION}${PHP_VARIANT}

################################################################################

INCLUDE ./meta

ADD --link ./rootfs/ /

################################################################################

# https://hyperf.wiki/3.1/#/en/quick-start/install
ENV DOCUMENT_ROOT=""
ENV INITIAL_PROJECT="hyperf/hyperf-skeleton"
ENV DISABLE_GENERATING_INDEX=1

################################################################################

RUN phpaddmod protobuf swoole
RUN web-cmd hyperf 'php $(app-path)/bin/hyperf.php'
RUN env-default PHP_SWOOLE_USE_SHORTNAME 'off'

RUN <<'EOF'
if has-cmd s6-service; then
    s6-service nginx depends hyperf
    s6-service hyperf longrun '#!/usr/bin/env sh
cd "$(app-path)"
wait-for-composer
exec php $(app-path)/bin/hyperf.php start
'
fi

EOF

