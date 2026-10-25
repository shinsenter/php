#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Runs every offline test (no Docker, no build). Exit code is non-zero when any fails.
#   ./tests/run.sh

cd "$(dirname "$0")" || exit 1

status=0
for test in lint.sh test-versions.sh test-backports.sh test-config.sh; do
    echo "== $test"
    bash "./$test" || status=1
done

exit $status
