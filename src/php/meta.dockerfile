################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# ARG BUILDPLATFORM
# ARG BUILDOS
# ARG BUILDARCH
# ARG BUILDVARIANT
# ARG TARGETPLATFORM
# ARG TARGETOS
# ARG TARGETARCH
# ARG TARGETVARIAN

ARG BUILD_REVISION
ARG BUILD_DATE
ARG BUILD_NAME="${BUILD_NAME:-shinsenter/php}"
ARG BUILD_TAG="${BUILD_TAG:-"$BUILD_NAME:latest"}"
ARG BUILD_DESC="${BUILD_DESC:-(PHP) A set of prebuilt PHP Docker images that simplify customization and extension installation.}"

ENV DOCKER_NAME="$BUILD_NAME"
ENV DOCKER_TAG="$BUILD_TAG"
ENV DOCKER_DATE="$BUILD_DATE"
ENV MAINTAINER="Mai Nhut Tan <shin@shin.company>"

LABEL org.opencontainers.image.authors="$MAINTAINER"
LABEL org.opencontainers.image.created="$BUILD_DATE"
LABEL org.opencontainers.image.description="$BUILD_DESC"
LABEL org.opencontainers.image.documentation="https://hub.docker.com/r/${BUILD_NAME}"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.revision="$BUILD_REVISION"
LABEL org.opencontainers.image.source="https://github.com/shinsenter/php"
LABEL org.opencontainers.image.title="$BUILD_NAME"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/${BUILD_NAME}/tags"
LABEL org.opencontainers.image.vendor="Docker Hub"
