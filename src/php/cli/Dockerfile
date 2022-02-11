# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
# FROM ${BASE_IMAGE:-shinsenter/s6-ubuntu:latest} as base
FROM test as base

# php version
ENV PHP_VERSION=${PHP_VERSION:-7.4}
ADD packages/php${PHP_VERSION}.txt /usr/src/php${PHP_VERSION}.txt

# adds composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        ca-certificates gnupg curl unzip libicu66 \
    \
    # adds ondrej repos for Ubuntu
    && echo 'deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main' \
        >/etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    \
    # installs php
    && apt-get install -y --no-install-recommends --no-install-suggests \
        $(cat /usr/src/php${PHP_VERSION}.txt) \
    && mv -f  /etc/php/${PHP_VERSION}/cli /etc/php/cli \
    && ln -sf /etc/php/cli /etc/php/${PHP_VERSION}/cli \
    \
    && apt-get -y autoremove && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

################################################################################

# main image
FROM base

# adds config files
ADD etc/ /etc/
RUN  /usr/bin/composer -v

CMD ["php", "-a"]

################################################################################