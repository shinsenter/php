#!/bin/bash
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Rules for src/php-backports/ (see "Security backports for EOL PHP" in CLAUDE.md).
# It does not apply the patches: that needs the source tree of that PHP version.

source "$(dirname "$0")/lib.sh"
source "$BASE_DIR/build/versions.sh"

ROOT="$BASE_DIR/src/php-backports"
NAME_RE='^[0-9]{8}-(10|90)-[A-Za-z0-9._-]+\.patch$'

for dir in "$ROOT"/php*/; do
    [ -d "$dir" ] || continue
    folder="$(basename "$dir")"
    version="${folder#php}"

    check "$folder: folder name is php<major.minor>" \
        bash -c '[[ "$1" =~ ^[0-9]+\.[0-9]+$ ]]' _ "$version"
    for maintained in "${MAINTAINED_PHP_VERSIONS[@]}"; do
        check_eq "$folder: version is still maintained" "no" \
            "$([ "${maintained%-rc}" = "$version" ] && echo yes || echo no)"
    done
    check "$folder: has at least one patch" \
        bash -c 'ls "$1"/*.patch' _ "$dir"

    for file in "$dir"*; do
        name="$(basename "$file")"
        rel="$folder/$name"

        check "$rel: name is <YYYYMMDD>-<10|90>-<name>[.alpine|.debian].patch" \
            bash -c '[[ "$1" =~ $2 ]]' _ "$name" "$NAME_RE"
        check "$rel: is mentioned in README.md" grep -qF "$name" "$ROOT/README.md"
        check "$rel: has a diff" grep -q '^diff ' "$file"
        check_not "$rel: touches NEWS" grep -q '^diff .* [ab]/NEWS' "$file"
        check_not "$rel: touches a .phpt test" grep -q '^diff .*\.phpt' "$file"

        month="${name:4:2}"
        day="${name:6:2}"
        check "$rel: date in the name is valid" \
            bash -c '[ "$((10#$1))" -ge 1 ] && [ "$((10#$1))" -le 12 ] && [ "$((10#$2))" -ge 1 ] && [ "$((10#$2))" -le 31 ]' _ "$month" "$day"

        # Security fixes (order 90) start with Backport-Fix lines
        case "$name" in
            ????????-90-*)
                check "$rel: starts with Backport-Fix:" \
                    bash -c 'head -n 1 "$1" | grep -q "^Backport-Fix: ."' _ "$file"
                while IFS= read -r line; do
                    text="${line#Backport-Fix: }"
                    check "$rel: Backport-Fix text is under 80 characters" \
                        [ "${#text}" -lt 80 ]
                done < <(sed -n '/^diff /q;/^Backport-Fix: /p' "$file")
                ;;
        esac
    done
done

finish
