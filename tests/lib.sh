#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Helpers shared by the offline tests (source this file, do not run it).
# Counters start at zero in every test file; `finish` prints the summary and
# returns non-zero when a check failed.

BASE_DIR="$(git rev-parse --show-toplevel)"
PASSED=0
FAILED=0

fail() {
    FAILED=$((FAILED + 1))
    echo "FAIL: $*" >&2
}

# check "<description>" <command...>: passes when the command succeeds
check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        PASSED=$((PASSED + 1))
    else
        fail "$description"
    fi
}

# check_not "<description>" <command...>: passes when the command fails
check_not() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        fail "$description"
    else
        PASSED=$((PASSED + 1))
    fi
}

# check_eq "<description>" <expected> <actual>
check_eq() {
    if [ "$2" = "$3" ]; then
        PASSED=$((PASSED + 1))
    else
        fail "$1 (expected '$2', got '$3')"
    fi
}

finish() {
    echo "$(basename "$0"): $PASSED passed, $FAILED failed"
    [ "$FAILED" -eq 0 ]
}
