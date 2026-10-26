#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Syntax check of every tracked shell script, and the no-tabs rule for the
# scripts of this project.

source "$(dirname "$0")/lib.sh"
cd "$BASE_DIR" || exit 1

while IFS= read -r -d '' file; do
    [ -f "$file" ] || continue
    case "$file" in
        build/docker-squash/*) continue ;;  # third-party
    esac

    first="$(head -n 1 "$file" 2>/dev/null | tr -d '\0')"
    case "$first" in
        '#!'*bash*) check "bash -n $file" bash -n "$file" ;;
        '#!'*sh*)   check "sh -n $file" sh -n "$file" ;;
    esac
done < <(git ls-files -z)

for file in tests/*.sh tests/tools/*.sh build/*.sh; do
    check_not "tab character in $file" grep -q "$(printf '\t')" "$file"
done

finish
