# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
FROM ${IMAGE_NAME:-shinsenter/php}:${PHP_VERSION:-7.4}-cli as base

# installs php-fpm
RUN apt-update && apt-install php${PHP_VERSION}-fpm \
    && swap-dir /etc/php/${PHP_VERSION}/fpm /etc/php/fpm \
    && sed -i -e 's/\[www\]/\[$\{PHP_POOL_NAME\}]/g' /etc/php/fpm/pool.d/www.conf \
    \
    # cleanup
    && apt-cleanup

# adds PHP configs
ENV PHP_DATE_TIMEZONE=${TZ:-UTC}
ENV PHP_DISPLAY_ERRORS=On
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT"
ENV PHP_MAX_EXECUTION_TIME=99
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_PM_CONTROL=dynamic
ENV PHP_PM_MAX_CHILDREN=20
ENV PHP_PM_MAX_SPARE_SERVERS=3
ENV PHP_PM_MIN_SPARE_SERVERS=1
ENV PHP_PM_START_SERVERS=2
ENV PHP_POOL_NAME=www
ENV PHP_POST_MAX_SIZE=100M
ENV PHP_UPLOAD_MAX_FILE_SIZE=100M

################################################################################

# main image
FROM base

# adds config files
ADD etc/ /etc/

EXPOSE 9000

################################################################################