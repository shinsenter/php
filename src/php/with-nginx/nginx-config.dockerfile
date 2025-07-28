################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-nginx/rootfs/ /

################################################################################

ENV PHP_LISTEN='/run/php-fpm.sock'

################################################################################

RUN <<'EOF'
echo 'Configure Nginx'

usermod -G $APP_GROUP,nginx nginx     >/dev/null 2>&1
usermod -G $APP_GROUP,nginx $APP_USER >/dev/null 2>&1

env-default '# Disable PHP-FPM logging to stdout'
env-default PHP_ACCESS_LOG '/var/log/php-fpm.log'

# create folders
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
    s6-service php-fpm longrun '#!/usr/bin/env sh
cd "$(app-path)"
exec php-fpm -y /usr/local/etc/php-fpm.d/zz-generated-settings.conf --nodaemonize --allow-to-run-as-root -d clear_env=no'

    s6-service nginx depends php-fpm
    s6-service nginx longrun '#!/usr/bin/env sh
export APP_PATH="$(app-path)"
export APP_ROOT="$(app-root)"

cd "$APP_PATH"
rm -rf ${NGINX_PID:-/run/nginx.pid}
exec nginx -g "daemon off;"
'
fi

EOF
