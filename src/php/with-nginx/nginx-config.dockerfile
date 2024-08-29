################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
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

# disable TLSv1.3 when not supported
if nginx-test 'invalid value "TLSv1.3"'; then
    echo 'Disable TLSv1.3 because it is not supported in this Nginx version'
    nginx-conf 'ssl_protocols' 'TLSv1.2'
fi

# fix deprecated listen http2 directive for Nginx 1.25.1
if nginx-test 'use the "http2" directive'; then
    sed -i 's/listen \(.\+\?\) http2/listen \1/g' /etc/nginx/sites-enabled/*.conf >/dev/null 2>&1
    echo "http2 on;" >/etc/nginx/custom.d/00-ext-http2.conf
fi

# customize extensions
if nginx-test 'brotli'; then rm -f /etc/nginx/custom.d/*brotli.conf; fi
if nginx-test 'gzip';   then rm -f /etc/nginx/custom.d/*gzip.conf;   fi
if nginx-test 'http3';  then rm -f /etc/nginx/custom.d/*http3.conf;  fi

# create s6 services
if has-cmd s6-service; then
    s6-service php-fpm longrun '#!/usr/bin/env sh
cd "$(app-path)"
exec php-fpm -y /usr/local/etc/php-fpm.d/zz-generated-settings.conf --nodaemonize --allow-to-run-as-root -d clear_env=no'

    s6-service nginx depends php-fpm
    s6-service nginx longrun '#!/usr/bin/env sh
export APP_PATH="$(app-path)"
export APP_ROOT="$(app-root)"

cd $APP_PATH
rm -rf ${NGINX_PID:-/run/nginx.pid}
exec nginx -g "daemon off;"
'
fi

EOF
