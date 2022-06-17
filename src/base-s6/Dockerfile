# This file belongs to the project https://code.shin.company/php
# Author:  Shin <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG BASE_OS_IMAGE=ubuntu:latest
ARG SCRATCH_IMAGE=shinsenter/scratch

################################################################################

# override scratch image
FROM ${SCRATCH_IMAGE} as scratch

################################################################################

# base image
FROM ${BASE_OS_IMAGE} as build

# changes the behavior of apt-get
ARG DEBIAN_FRONTEND=noninteractive

# sets version for s6 overlay
ARG S6_DIR=/opt/s6/
ARG S6_SRC_DEP="ca-certificates xz-utils wget"
ARG S6_SRC_URL="https://github.com/just-containers/s6-overlay/releases/download"
ARG S6_VERSION

# checks build argument
RUN if [ -z "$S6_VERSION" ]; then \
        echo "Please set S6_VERSION build argument."; exit 1; \
    fi

# adds build dependencies
RUN mkdir -p $S6_DIR
RUN apt-get update  -yqq
RUN apt-get install -yq $S6_SRC_DEP --no-install-recommends --no-install-suggests
RUN ln -sf /etc/ssl/certs/ca-certificates.crt /usr/lib/ssl/cert.pem

# detect system arch then select the right version of s6
RUN export SYS_ARCH=$(uname -m); \
    case "$SYS_ARCH" in \
        aarch64 ) export S6_ARCH='aarch64' ;; \
        arm64   ) export S6_ARCH='aarch64' ;; \
        armhf   ) export S6_ARCH='armhf'   ;; \
        arm*    ) export S6_ARCH='arm'     ;; \
        i4*     ) export S6_ARCH='i486'    ;; \
        i6*     ) export S6_ARCH='i686'    ;; \
        riscv64 ) export S6_ARCH='riscv64' ;; \
        s390*   ) export S6_ARCH='s390x'   ;; \
        *       ) export S6_ARCH='x86_64'  ;; \
    esac; \
    untar (){ \
        echo "  ⏬ Downloading $1"; \
        wget -O- $1 | tar Jxp -C "${2:-$S6_DIR}"; \
    }; \
    \
    echo "⬇️ Downloading s6 overlay:${S6_ARCH}-${S6_VERSION} for ${SYS_ARCH}" \
        && untar ${S6_SRC_URL}/${S6_VERSION}/s6-overlay-noarch.tar.xz \
        && untar ${S6_SRC_URL}/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz \
        && untar ${S6_SRC_URL}/${S6_VERSION}/syslogd-overlay-noarch.tar.xz \
        && du -sh $S6_DIR

################################################################################

# the main image
FROM scratch

# copies from from build stage
COPY --from=build /opt/s6/ /

################################################################################