#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Builds each platform, squashes it to one layer with docker-squash, pushes it
# by digest, then joins the digests into the multi-platform tags.
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

names="$(IFS=,; echo "${REPOS[*]}")"
digests=()

for platform in "${PLATFORMS[@]}"; do
    slug="${platform//\//-}"
    temp="dockerfile-x-build:$slug"

    docker buildx build --pull --load --platform "$platform" -t "$temp" \
        -f "$CONTEXT/build.dockerfile" "$CONTEXT"
    "$SQUASH" "$temp" -p > "$WORK/$slug.dockerfile"
    docker image rm -f "$temp" >/dev/null

    docker buildx build --platform "$platform" --provenance=true --sbom=true \
        --metadata-file "$WORK/$slug.json" \
        --output "type=image,\"name=$names\",push-by-digest=true,name-canonical=true,push=true" \
        -f "$WORK/$slug.dockerfile" "$CONTEXT"
    digests+=("$(jq -r '."containerimage.digest"' "$WORK/$slug.json")")
done

for repo in "${REPOS[@]}"; do
    docker buildx imagetools create \
        $(printf -- "-t $repo:%s " "${VERSIONS[@]}") \
        $(printf -- "$repo@%s " "${digests[@]}")
done

# docker scout cves shinsenter/dockerfile-x:latest
