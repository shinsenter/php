#!/bin/sh -e
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

BASE_DIR="$(git rev-parse --show-toplevel)"

act workflow_dispatch --dryrun \
    --network host \
    --container-architecture linux/amd64 \
    --workflows "$BASE_DIR/.github/workflows/build-all.yml" \
    "$@"
