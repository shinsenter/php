################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-nginx/rootfs/ /

################################################################################

RUN <<'EOF'
echo 'Configure Nginx'

# add user to nginx group
SUPP_GROUPS=$(id -Gn "$APP_USER" | tr ' ' ',')
usermod -G $APP_GROUP,nginx nginx &>/dev/null || true
usermod -G $SUPP_GROUPS,nginx $APP_USER &>/dev/null || true

# disable PHP-FPM logging to stdout
env-default PHP_LISTEN '/run/php-fpm.sock'
env-default PHP_ACCESS_LOG '/var/log/php-fpm.log'

# create directories
mkdir -p /etc/nginx \
    /etc/nginx/custom.d \
    /etc/nginx/modules-enabled \
    /etc/nginx/sites-enabled \
    /var/tmp/nginx \
    /var/tmp/nginx/client_body \
    /var/tmp/nginx/proxy \
    /var/tmp/nginx/fastcgi \
    /var/tmp/nginx/uwsgi \
    /var/tmp/nginx/scgi \
    /var/lib/nginx /var/log/nginx /run/nginx

# create s6 services
if has-cmd s6-service; then
    s6-service nginx depends php-fpm
    s6-service nginx longrun '#!/usr/bin/env sh
NGINX_PID="${NGINX_PID:-/run/nginx.pid}"
\rm -rf "$NGINX_PID" || true
exec wait-for-socket "$PHP_LISTEN" \
    nginx -g "daemon off;user $APP_USER $APP_GROUP;pid $NGINX_PID;" \
    || /run/s6/basedir/bin/halt
'
fi

EOF
