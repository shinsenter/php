################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Here are php.ini directives we can set to configure our PHP setup
# See: https://www.php.net/manual/en/ini.list.php
# See: https://www.php.net/manual/en/install.fpm.configuration.php

RUN <<'EOF'
echo 'Configure PHP'

set -e

# Choose default php.ini
if [ ! -e ${PHP_INI_DIR}/php.ini ] && [ -f ${PHP_INI_DIR}/php.ini-production ]; then
    mv -f ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini
fi

# Override defaults to securely configure PHP settings
# See: https://www.php.net/manual/en/session.security.ini.php
env-default '# Override defaults for PHP'
env-default PHP_ALLOW_URL_INCLUDE '0'
env-default PHP_DATE_TIMEZONE '${TZ:=UTC}'
env-default PHP_DISPLAY_ERRORS '0'
env-default PHP_ERROR_LOG '$(log-path)'
env-default PHP_EXPOSE_PHP '0'
env-default PHP_FASTCGI_LOGGING 'Off'
env-default PHP_MAIL_LOG '$(log-path)'
env-default PHP_MEMORY_LIMIT '256M'
env-default PHP_OPCACHE_ENABLE '1'
env-default PHP_OPCACHE_ERROR_LOG '$(log-path)'
env-default PHP_OPCACHE_FAST_SHUTDOWN '1'
env-default PHP_OPCACHE_JIT_DEBUG '$(is-debug && echo 1 || echo 0)'
env-default PHP_OPCACHE_MAX_ACCELERATED_FILES '130987'
env-default PHP_OPCACHE_PRELOAD_USER '$APP_GROUP'
env-default PHP_POST_MAX_SIZE '100M'
env-default PHP_REPORT_ZEND_DEBUG '$(is-debug && echo 1 || echo 0)'
env-default PHP_REQUEST_ORDER 'GP'
env-default PHP_SESSION_COOKIE_HTTPONLY '1'
env-default PHP_SESSION_COOKIE_LIFETIME '0'
env-default PHP_SESSION_COOKIE_SAMESITE 'Lax'
env-default PHP_SESSION_COOKIE_SECURE '0'
env-default PHP_SESSION_USE_COOKIES '1'
env-default PHP_UPLOAD_MAX_FILESIZE '100M'
env-default PHP_USER_AGENT 'PHP${PHP_VERSION} Docker(https://hub.docker.com/r/${IMAGE_NAME:-shinsenter/php})'
env-default PHP_VARIABLES_ORDER 'EGPCS'
if [ ! -z "$SENDMAIL_PATH" ]; then env-default PHP_SENDMAIL_PATH '$SENDMAIL_PATH'; fi
if [ ! -z "$SENDMAIL_FROM" ]; then env-default PHP_SENDMAIL_FROM '$SENDMAIL_FROM'; fi

# Override defaults for PHP-FPM
env-default '# Override defaults for PHP-FPM'
env-default PHP_LISTEN '9000'
env-default PHP_LISTEN_GROUP '$APP_GROUP'
env-default PHP_LISTEN_OWNER '$APP_USER'
env-default PHP_LISTEN_MODE '0660'
env-default PHP_GROUP '$APP_GROUP'
env-default PHP_USER '$APP_USER'
env-default PHP_POOL_NAME 'www'
env-default PHP_ACCESS_LOG '$(log-path)'
env-default PHP_ACCESS_FORMAT '%R - %u %t "%m %r%Q%q" %s %{HTTP_HOST}e%{REQUEST_URI}e %{seconds}d %{kilo}M %C%% %{HTTP_REFERER}e'
env-default PHP_ERROR_LOG '$(log-path)'
env-default PHP_SLOWLOG '$(log-path)'
env-default PHP_LOG_LEVEL 'notice'
env-default PHP_PING_PATH '/ping'
env-default PHP_PING_RESPONSE 'pong'
env-default PHP_PID '/run/php-fpm.pid'
env-default PHP_PM 'ondemand'
env-default PHP_PM_MAX_CHILDREN '5'
env-default PHP_PM_MAX_REQUESTS '0'
env-default PHP_PM_MAX_SPARE_SERVERS '3'
env-default PHP_PM_MAX_SPAWN_RATE '32'
env-default PHP_PM_MIN_SPARE_SERVERS '1'
env-default PHP_PM_START_SERVERS '2'
env-default PHP_PM_STATUS_LISTEN '/run/php-fpm-status.sock'
env-default PHP_PM_STATUS_PATH '/status/php-fpm'
env-default PHP_SYSLOG_FACILITY 'syslog'

################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
################################################################################
EOF
