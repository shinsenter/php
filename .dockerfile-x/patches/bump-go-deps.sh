#!/bin/sh
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Raises vulnerable Go modules listed in patches/go-deps. Run in a Go module root.
set -eu

GOFLAGS=-mod=mod
export GOFLAGS

while read -r dep; do
    case "$dep" in ''|'#'*) continue ;; esac
    if go list -m "${dep%@*}" >/dev/null 2>&1; then
        echo "bump $dep"
        go get "$dep"
    fi
done < "$(dirname "$0")/go-deps"

go mod tidy
[ ! -d vendor ] || go mod vendor
