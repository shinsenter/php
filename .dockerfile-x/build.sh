#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"
SOURCE="devthefuture/dockerfile-x:1.4.5"

TAGS=(
shinsenter/dockerfile-x:v1
shinsenter/dockerfile-x:latest
ghcr.io/shinsenter/dockerfile-x:latest
ghcr.io/shinsenter/dockerfile-x:v1
)

echo "# syntax=docker/dockerfile:1
FROM $SOURCE
LABEL org.opencontainers.image.source=https://codeberg.org/devthefuture/dockerfile-x" | \
exec docker buildx build \
    --pull --push --squash \
    --platform linux/amd64,linux/arm64/v8 \
    --provenance=true --sbom=true --attest type=sbom \
    $(printf -- "-t %s " "${TAGS[@]}") -
