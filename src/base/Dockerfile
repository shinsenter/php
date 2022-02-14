# This pipeline will keep image size as small as possible.
################################################################################

# base image and platform
FROM ${OS_BASE:-ubuntu}:${OS_VERSION:-focal} as base

# adds labels
LABEL base_image="${OS_BASE:-ubuntu}:${OS_VERSION:-focal}"
LABEL publisher="shinsenter"
LABEL maintainer="admin@appseeds.net"

# sets environment variables for platform
ENV OS_BASE=${OS_BASE:-ubuntu}
ENV OS_VERSION=${OS_VERSION:-focal}

# sets environment variables for OS
ENV TERM=xterm
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C
ENV LANG=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV TZ=UTC

# common methods
ADD usr/ /usr/

################################################################################

# extracts s6-overlay bundles into a temporary image
FROM base as source

# sets version for s6 overlay
ARG S6_SRC="http://github.com/just-containers/s6-overlay/releases/download"
ARG S6_ARCH="aarch64"
ARG S6_VERSION="3.0.0.2"
ARG S6_BUILD_DEP="ca-certificates xz-utils wget"

# installation pipeline
RUN apt-update && apt-install $S6_BUILD_DEP \
    \
    # adds s6 overlay
    && mkdir -p /usr/src/s6 \
    && untar(){ wget -O- $1 2>/dev/null | tar Jxp -C ${2:-/usr/src/s6/}; } \
    && untar ${S6_SRC}/v${S6_VERSION}/s6-overlay-noarch-${S6_VERSION}.tar.xz \
    && untar ${S6_SRC}/v${S6_VERSION}/s6-overlay-${S6_ARCH}-${S6_VERSION}.tar.xz

################################################################################

# main image
FROM base

# sets environment variables for user
ENV PUID=9999 
ENV PGID=9999
ENV HOME=/root
ENV WEBHOME="/var/www/html" 

# adds user and group
RUN groupadd -r -g $PGID webgroup
RUN useradd  -r -g $PGID -u $PUID -d $WEBHOME \
                -s /usr/bin/bash --no-log-init webuser

# copies s6-overlay from source
COPY --from=source /usr/src/s6/ /
ADD  etc/ /etc/

WORKDIR     $WEBHOME
ENTRYPOINT  ["/init"]

################################################################################