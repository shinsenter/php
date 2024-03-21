# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_IMAGE=shinsenter/phpfpm-nginx
ARG IMAGE_SUFFIX="-tidy"
ARG PHP_VERSION=8.3

################################################################################

# base image
FROM ${BASE_IMAGE}:php${PHP_VERSION}${IMAGE_SUFFIX}-deprecated

# sets web server root path
ENV NGINX_DOCUMENT_ROOT=""

################################################################################

# adds config files
ADD root/ /

# sets the working directory
# WORKDIR $WEBHOME

################################################################################

# overrides parents env variables
ENV PHP_MAX_EXECUTION_TIME=600
ENV PHP_MEMORY_LIMIT=512M
ENV PHP_POST_MAX_SIZE=2G
ENV PHP_UPLOAD_MAX_FILE_SIZE=2G

# phpmyadmin settings
ENV PMA_ARBITRARY=1
ENV PMA_HOST=mysql
# ENV PMA_ABSOLUTE_URI=
# ENV PMA_ARBITRARY=
# ENV PMA_BLOWFISH_SECRET=
# ENV PMA_CONTROLHOST=
# ENV PMA_CONTROLPASS=
# ENV PMA_CONTROLPORT=
# ENV PMA_CONTROLUSER=
# ENV PMA_DEFAULTLANG=
# ENV PMA_HOST=
# ENV PMA_HOSTS=
# ENV PMA_MAXROWS=
# ENV PMA_PASSWORD=
# ENV PMA_PMADB=
# ENV PMA_PORT=
# ENV PMA_PORTS=
# ENV PMA_PROPERTIESNUMCOLUMNS=
# ENV PMA_PROTECTBINARY=
# ENV PMA_QUERYHISTORYDB=
# ENV PMA_QUERYHISTORYMAX=
# ENV PMA_ROWACTIONTYPE=
# ENV PMA_SENDERRORREPORTS=
# ENV PMA_SHOWALL=
# ENV PMA_SOCKET=
# ENV PMA_SOCKETS=
# ENV PMA_URLQUERYENCRYPTION=
# ENV PMA_URLQUERYENCRYPTIONSECRETKEY=
# ENV PMA_USER=
# ENV PMA_VERBOSE=
# ENV PMA_VERBOSES=

################################################################################
