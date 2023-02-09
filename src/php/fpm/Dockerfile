# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.2

################################################################################

# base image
FROM ${BASE_IMAGE}:${PHP_VERSION}-cli

# adds PHP configs
ARG PHP_POOL_NAME=www
ARG PHPFPM_SOCK_PATH=/var/run/php/php-fpm.sock

################################################################################

# installs php-fpm
RUN apt-update \
    && apt-install php${PHP_VERSION}-fpm msmtp msmtp-mta \
    && disable php${PHP_VERSION}-fpm \
    && swap-dir /etc/php/${PHP_VERSION}/fpm /etc/php/fpm \
    && sed -i -e 's/\[www\]/\[$\{PHP_POOL_NAME\}]/g' /etc/php/fpm/pool.d/www.conf \
    && ln -sf /etc/php/fpm /usr/local/etc/php-fpm \
    && ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm \
    \
    # cleanup
    && rm -rf /var/log/php-fpm \
    && apt-upgrade -uq \
    && cleanup

# adds config files
ADD root/ /

# opcache preload
RUN if [ "$(php -r 'echo PHP_VERSION_ID;')" -ge "70400" ]; then \
    echo '' >>/etc/php/fpm/pool.d/x-override-php-defaults.conf; \
    echo 'php_value[opcache.preload] = ${PHP_OPCACHE_PRELOAD}' >>/etc/php/fpm/pool.d/x-override-php-defaults.conf; \
    echo 'php_value[opcache.preload_user] = ${PHP_OPCACHE_PRELOAD_USER}' >>/etc/php/fpm/pool.d/x-override-php-defaults.conf; \
fi

# opcache jit
RUN if [ "$(php -r 'echo PHP_VERSION_ID;')" -ge "80000" ]; then \
    echo '' >>/etc/php/fpm/pool.d/x-override-php-defaults.conf; \
    echo 'php_value[opcache.jit] = ${PHP_OPCACHE_JIT}' >>/etc/php/fpm/pool.d/x-override-php-defaults.conf; \
    echo 'php_value[opcache.jit_buffer_size] = ${PHP_OPCACHE_BUFFER_SIZE}' >>/etc/php/fpm/pool.d/x-override-php-defaults.conf; \
fi

# sets the working directory
# WORKDIR $WEBHOME

# exposes port
EXPOSE 9000

# sets default entrypoint
ENTRYPOINT ["/init"]

################################################################################

# adds MSMTP settings
ENV MSMTP_RELAY_SERVER_HOSTNAME=mailhog
ENV MSMTP_RELAY_SERVER_PORT=1025

# adds more PHP variables for php-fpm
ENV PHP_DEFAULT_CHARSET=UTF-8
ENV PHP_DISPLAY_ERRORS=On
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"
ENV PHP_MAX_EXECUTION_TIME=99
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILE_SIZE=10M
ENV PHP_UPLOAD_MAX_INPUT_VARS=1000

# adds PHP-FPM settings
ENV PHP_POOL_NAME="$PHP_POOL_NAME"
ENV PHPFPM_CONF_DIR=/etc/php/fpm/conf.d
ENV PHPFPM_SOCK_PATH="$PHPFPM_SOCK_PATH"

# adds PHP PM settings
ENV PHP_PM_CONTROL=ondemand
ENV PHP_PM_MAX_CHILDREN=5
ENV PHP_PM_MAX_SPARE_SERVERS=3
ENV PHP_PM_MIN_SPARE_SERVERS=1
ENV PHP_PM_START_SERVERS=2

# adds other Opcache settings
ENV PHP_OPCACHE_INTERNED_STRINGS_BUFFER=64
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=130987
ENV PHP_OPCACHE_MAX_WASTED_PERCENTAGE=15
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=256
ENV PHP_OPCACHE_PRELOAD_USER="${WEBUSER:-www-data}"
ENV PHP_OPCACHE_PRELOAD=
ENV PHP_OPCACHE_REVALIDATE_FREQ=5
ENV PHP_OPCACHE_REVALIDATE_PATH=0
ENV PHP_OPCACHE_SAVE_COMMENTS=1
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=1
ENV PHP_OPCACHE_JIT=tracing
ENV PHP_OPCACHE_BUFFER_SIZE=128M

################################################################################