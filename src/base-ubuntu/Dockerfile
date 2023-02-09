# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG SCRATCH_IMAGE=shinsenter/scratch
ARG BASE_S6_IMAGE=shinsenter/s6-overlay
ARG BASE_OS_IMAGE=ubuntu:latest
ARG S6_VERSION=latest

################################################################################

# override scratch image
FROM ${SCRATCH_IMAGE} as scratch

################################################################################

# s6 source image
FROM ${BASE_S6_IMAGE}:${S6_VERSION} as s6

################################################################################

# base image
FROM ${BASE_OS_IMAGE} as base

# sets defaults
ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_DEPS="apt-utils"

################################################################################

# adds binaries
ADD root/ /

# copies s6-overlay from source
COPY --from=s6 / /

# updates packages
RUN echo "🤖 Updating packages"
RUN apt-update
RUN apt-install $BUILD_DEPS ca-certificates cron openssl
RUN ln -sf /etc/ssl/certs/ca-certificates.crt /usr/lib/ssl/cert.pem
RUN disable cron
RUN apt-upgrade -uq
RUN cleanup $BUILD_DEPS

################################################################################

# the main image
FROM  scratch
SHELL ["/bin/bash", "-c"]

# sets defaults
ARG WEBUSER=www-data
ARG WEBGROUP=www-data

# copies from from build stage
COPY --from=base / /

# sets the working directory
WORKDIR /root

# sets default command
CMD ["/bin/bash"]

################################################################################

# S6 variables
ARG S6_VERSION
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=600000
ENV S6_KEEP_ENV=1
ENV S6_KILL_FINISH_MAXTIME=3000
ENV S6_KILL_GRACETIME=3000
ENV S6_LOGGING=1
ENV S6_SERVICES_GRACETIME=3000
ENV S6_VERBOSITY=1
ENV S6_VERSION=$S6_VERSION

# sets WEBUSER and WEBGROUP
ENV WEBUSER="$WEBUSER"
ENV WEBGROUP="$WEBGROUP"
ENV WEBHOME="/var/www/html"

# adds OS variables
ENV DEBUG_MODE=false
ENV ENABLE_CRONTAB=false
ENV HOME=/root
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C
ENV PATH=/command:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV SHELL=/bin/bash
ENV TERM=xterm

################################################################################