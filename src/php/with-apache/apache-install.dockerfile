################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  SHIN Company <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ENV APACHE_PID=/run/apache2.pid

# Install Apache2
RUN <<'EOF'
echo 'Install Apache2'
[ -z "$DEBUG" ] || set -ex && set -e

# install apache
APK_PACKAGES="apache2 apache2-proxy apache2-ssl apache2-utils" \
APT_PACKAGES="apache2" \
pkg-add

# clean up
rm -rf /etc/init.d/apache* \
    /etc/ssl/apache* \
    /var/www \
    /etc/apache2/modules* \
    /etc/apache2/conf.d \
    /etc/apache2/conf-*/* \
    /etc/apache2/mods-*/* \
    /etc/apache2/sites-*/* \
    /etc/apache2/apache2.conf \
    /etc/apache2/httpd.conf \
    /etc/apache2/ports.conf \
    $APP_PATH/*

# copy mime types
if [ -f /etc/mime.types ]; then
    cp -rf /etc/mime.types /etc/apache2/mime.types
fi

# link modules directory
module_dir="$(dirname $(find /usr/lib/ -type f -name mod_mpm_event.so | head -n 1))"
if [ -d "$module_dir" ]; then
    rm -rf /etc/apache2/modules
    ln -nsf "$module_dir" /etc/apache2/modules

    if has-cmd strip; then
        strip --strip-all --strip-debug "$module_dir"/*.so
    fi
fi

# alias for apache2
if has-cmd httpd && ! has-cmd apache2; then
    ln -nsf "$(command -v httpd)" "/usr/local/sbin/apache2"
fi

EOF
