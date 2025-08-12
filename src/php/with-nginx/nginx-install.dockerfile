################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ENV NGINX_PID=/run/nginx.pid

# Install Nginx
RUN <<'EOF'
echo 'Install Nginx'
[ -z "$DEBUG" ] || set -ex && set -e

# install nginx
pkg-add nginx

# clean up
rm -rf /var/www/localhost \
    /etc/init.d/nginx* \
    /etc/ssl/nginx* \
    /etc/nginx/nginx.conf \
    /etc/nginx/http.d \
    /etc/nginx/modules-* \
    /etc/nginx/sites-* \
    /etc/nginx/conf-* \
    "$APP_PATH"/*
EOF
