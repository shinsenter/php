# This file is the work of https://github.com/shinsenter/php
################################################################################

ARG BASE_IMAGE=shinsenter/php
ARG PHP_VERSION=8.1

################################################################################

# base image and platform
FROM ${BASE_IMAGE}:${PHP_VERSION}-fpm-nginx

# adds config files
ADD root/ /

# updates document root path
ENV NGINX_DOCUMENT_ROOT=$WEBHOME

# sets the working directory
WORKDIR $NGINX_DOCUMENT_ROOT

################################################################################

# overrides parents env variables
ENV PHP_MAX_EXECUTION_TIME=600
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_POST_MAX_SIZE=2G
ENV PHP_UPLOAD_MAX_FILE_SIZE=2G

# phpmyadmin settings
ENV PMA_ARBITRARY=1
ENV PMA_HOST=mysql
# ENV PMA_HOSTS=
# ENV PMA_VERBOSE=
# ENV PMA_VERBOSES=
# ENV PMA_PORT=
# ENV PMA_PORTS=
# ENV PMA_SOCKET=
# ENV PMA_SOCKETS=
# ENV PMA_USER=
# ENV PMA_PASSWORD=
# ENV PMA_ABSOLUTE_URI=
# ENV PMA_CONTROLHOST=
# ENV PMA_CONTROLPORT=
# ENV PMA_PMADB=
# ENV PMA_CONTROLUSER=
# ENV PMA_CONTROLPASS=
# ENV PMA_QUERYHISTORYDB=
# ENV PMA_QUERYHISTORYMAX=

################################################################################

ARG   BUILD_NUMBER
LABEL build_number="$BUILD_NUMBER"