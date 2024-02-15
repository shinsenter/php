################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-nginx/rootfs/ /

################################################################################

ENV PHP_LISTEN='/run/php-fpm.sock'

################################################################################

RUN <<'EOF'
echo 'Configure Nginx'

env-default '# Disable PHP-FPM logging to stdout'
env-default PHP_ACCESS_LOG '/var/log/php-fpm.log'

# create folders
mkdir -p /etc/nginx \
    /etc/nginx/custom.d \
    /etc/nginx/modules-enabled \
    /etc/nginx/sites-enabled \
    /var/lib/nginx /var/log/nginx /run/nginx

# create s6 services
if has-cmd s6-service; then
    s6-service php-fpm longrun '#!/usr/bin/env sh
exec php-fpm -y /usr/local/etc/php-fpm.d/zz-generated-settings.conf --nodaemonize'

    s6-service nginx depends php-fpm
    s6-service nginx longrun '#!/usr/bin/env sh
web-chown fix /var/lib/nginx /var/log/nginx /run/nginx

rm -f ${NGINX_PID:-/run/nginx.pid}
cd "$(app-path)"
exec nginx -g "daemon off;"
'
fi

EOF
