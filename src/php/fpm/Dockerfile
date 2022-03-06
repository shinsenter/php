# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-cli

# adds PHP configs
ENV PHP_POOL_NAME=www

# installs php-fpm
RUN apt-update && apt-install php${PHP_VERSION}-fpm \
    && service php${PHP_VERSION}-fpm stop && update-rc.d php${PHP_VERSION}-fpm disable \
    && swap-dir /etc/php/${PHP_VERSION}/fpm /etc/php/fpm \
    && sed -i -e 's/\[www\]/\[$\{PHP_POOL_NAME\}]/g' /etc/php/fpm/pool.d/www.conf \
    && ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm \
    \
    # makes log files
    && webuser-mkdir /var/log/php-fpm \
    && ln -sf /dev/stdout /var/log/php-fpm/access.log \
    && ln -sf /dev/stderr /var/log/php-fpm/error.log \
    \
    # cleanup
    && apt-cleanup

################################################################################

# adds config files
ADD root/ /

# resets the entrypoint
ENTRYPOINT ["/init"]
EXPOSE 9000

################################################################################

# adds more PHP variables for php-fpm
ENV PHP_DATE_TIMEZONE=${TZ:-UTC}
ENV PHP_DISPLAY_ERRORS=On
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"
ENV PHP_MAX_EXECUTION_TIME=99
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_PM_CONTROL=ondemand
ENV PHP_PM_MAX_CHILDREN=20
ENV PHP_PM_MAX_SPARE_SERVERS=3
ENV PHP_PM_MIN_SPARE_SERVERS=1
ENV PHP_PM_START_SERVERS=2
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILE_SIZE=100M
ENV PHPFPM_CONF_DIR=/etc/php/fpm/conf.d

# adds other Opcache settings
ENV PHP_OPCACHE_ENABLE_CLI=0
ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_FAST_SHUTDOWN=1
ENV PHP_OPCACHE_INTERNED_STRINGS_BUFFER=8
ENV PHP_OPCACHE_MAX_ACCELERATED_FILES=1048793
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=128
ENV PHP_OPCACHE_PRELOAD_USER=webuser
ENV PHP_OPCACHE_PRELOAD=
ENV PHP_OPCACHE_REVALIDATE_FREQ=2
ENV PHP_OPCACHE_REVALIDATE_PATH=0
ENV PHP_OPCACHE_SAVE_COMMENTS=1
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=1

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"