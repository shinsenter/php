#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Builds each platform, squashes it to one layer with docker-squash, pushes it
# to a per-platform tag, then joins those tags into the multi-platform tags.
# The docker driver cannot push by digest, so the build-<platform> tags stay.
set -e

BASE_DIR="$(git rev-parse --show-toplevel)"
CONTEXT="$BASE_DIR/.dockerfile-x"
SQUASH="$BASE_DIR/build/docker-squash/docker-squash.sh"
WORK="$(mktemp -d)"

REPOS=(shinsenter/dockerfile-x ghcr.io/shinsenter/dockerfile-x)
VERSIONS=(v1 latest)
PLATFORMS=(linux/amd64 linux/arm64/v8)

trap 'rm -rf "$WORK"' EXIT
git -C "$BASE_DIR" submodule update --init .dockerfile-x/upstream

sources=()

for platform in "${PLATFORMS[@]}"; do
    slug="${platform//\//-}"
    temp="dockerfile-x-build:$slug"

    docker buildx build --pull --load --platform "$platform" -t "$temp" \
        -f "$CONTEXT/build.dockerfile" "$CONTEXT"
    "$SQUASH" "$temp" -p > "$WORK/$slug.dockerfile"

    docker buildx build --platform "$platform" --provenance=true --sbom=true \
        --push $(printf -- "-t %s:build-$slug " "${REPOS[@]}") \
        -f "$WORK/$slug.dockerfile" "$CONTEXT"
    sources+=("build-$slug")
    docker image rm -f "$temp" >/dev/null
done

for repo in "${REPOS[@]}"; do
    docker buildx imagetools create \
        $(printf -- "-t $repo:%s " "${VERSIONS[@]}") \
        $(printf -- "$repo:%s " "${sources[@]}")
done

# docker scout cves shinsenter/dockerfile-x:latest
