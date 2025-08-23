################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ADD --link ./with-apache/rootfs/ /

################################################################################

RUN <<'EOF'
echo 'Configure Apache2'

env-default '# Environment variables for Apache2'
env-default APACHE_LOG_LEVEL 'error'
env-default APACHE_ERROR_LOG '$(log-path stderr)'
env-default APACHE_ACCESS_LOG '$(log-path stdout)'
env-default APACHE_MAX_CONNECTIONS_PER_CHILD '0'
env-default APACHE_MAX_REQUEST_WORKERS '150'
env-default APACHE_MAX_SPARE_SERVERS '10'
env-default APACHE_MAX_SPARE_THREADS '75'
env-default APACHE_MIN_SPARE_SERVERS '5'
env-default APACHE_MIN_SPARE_THREADS '10'
env-default APACHE_START_SERVERS '2'
env-default APACHE_THREADS_PER_CHILD '25'

# disable PHP-FPM logging to stdout
env-default PHP_LISTEN '/run/php-fpm.sock'
env-default PHP_ACCESS_LOG '/var/log/php-fpm.log'

CONF_FILE=/etc/apache2/apache2.conf
MODS_FILE=/etc/apache2/modules.conf

if [ -f "$CONF_FILE" ]; then
    # detect available modules
    if [ -d /etc/apache2/modules ]; then
        echo -e "# Begin Modules\n# End Modules" >$MODS_FILE
        for module_path in /etc/apache2/modules/*.so ; do
            module="${module_path##*mod_}"
            module="${module/.so/_module}"
            echo "Found ${module} at ${module_path}"
            sed -i "s|^# End Modules|#LoadModule ${module} ${module_path}\n# End Modules|" $MODS_FILE >/dev/null 2>&1
        done
    fi

    # copy production config
    if has-cmd httpd; then
        mv -f "$CONF_FILE" /etc/apache2/httpd.conf
    fi
fi

# create directories
mkdir -p /etc/apache2 \
    /etc/apache2/custom.d \
    /etc/apache2/conf-enabled \
    /etc/apache2/mods-enabled \
    /etc/apache2/sites-enabled \
    /run/apache2 \
    /var/lib/apache2 \
    /var/log/apache2 \
    /usr/logs

# configure default modules
a2dismod ado auth_digest autoindex cgi dav dbd include info mpm_prefork php reqtimeout userdir 2>&1 || true
a2enmod \
    access_compat alias auth_basic authn_core authn_file authz_core authz_host \
    cache cgid deflate dir env expires filter headers http2 log_config mime mime_magic \
    mpm_event negotiation proxy proxy_fcgi remoteip rewrite setenvif ssl status unixd 2>&1 || true

# fix ProxyFCGIBackendType directive for Apache 2.4
if apache-has-error 'ProxyFCGIBackendType'; then
    echo 'Disable ProxyFCGIBackendType because it is not supported in this Apache version'
    sed -i 's/ProxyFCGIBackendType/#ProxyFCGIBackendType/g' $CONF_FILE
fi

# create s6 services
if has-cmd s6-service; then
    s6-service apache requires php-fpm
    s6-service apache longrun '#!/usr/bin/env sh
if [ -f /etc/apache2/envvars ]; then source /etc/apache2/envvars; fi
\rm -f "${APACHE_PID:-/run/apache2.pid}" || true
exec wait-for "$(s6-service nginx depends php-fpm && echo $PHP_LISTEN)" \
    apache2 -E "$(log-path stderr)" -DFOREGROUND $(is-debug && echo '-X')
'
fi

EOF
