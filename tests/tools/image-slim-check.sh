#!/bin/sh -e
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Look for size that can still be removed from a built image.
# Read-only: it runs a probe in a throwaway container and changes nothing.
# Exit 1 when it finds a package, file or binary that should not be in the image.
#
# Usage: tests/tools/image-slim-check.sh <image> [threshold-MB]
#   For example: tests/tools/image-slim-check.sh ghcr.io/shinsenter/phpfpm-nginx:php8.4 1
################################################################################

IMAGE="${1:?Usage: ${0##*/} <image> [threshold-MB]}"
THRESHOLD_KB="$(( ${2:-1} * 1024 ))"

# The probe runs inside the image, as one string passed to "sh -c".
# It uses POSIX sh and busybox-safe options, so one script serves Debian and Alpine.
# Inside the string: use double quotes only, and escape $ and " when the host shell would expand them.
# Every line that starts with "WARN:" counts as a finding and makes the script exit 1.
PROBE='
warn() { echo "WARN: $*"; }
# KB to MB, rounded up
mb() { echo "$(( ($1 + 1023) / 1024 ))"; }

# Debian has dpkg, Alpine has apk
if command -v dpkg >/dev/null 2>&1; then OS=debian; else OS=alpine; fi
echo "== Summary ($OS)"
echo "disk: $(du -xsm / 2>/dev/null | cut -f1) MB"
echo "extensions: $(php -m 2>/dev/null | grep -v "^\[" | grep -c .)"

# files first: probing packages with apk writes to /var/cache
echo "== Leftover files"
n="$(command -v nginx 2>/dev/null || true)"
[ -z "$n" ] || [ ! -e "$n.old" ] || warn "file $n.old"
for d in /usr/share/doc /usr/share/man /usr/share/info /usr/share/locale /var/cache /var/lib/apt/lists /var/log /tmp /root/.cache /root/.composer; do
    [ -d "$d" ] || continue
    kb="$(du -sk "$d" 2>/dev/null | cut -f1)"
    [ "${kb:-0}" -le '"$THRESHOLD_KB"' ] || warn "directory $d is $(mb "$kb") MB"
done

echo "== Leftover packages"
if [ "$OS" = debian ]; then
    # dpkg -l is used because old dpkg has no db:Status-Status
    dpkg -l 2>/dev/null | awk "/^ii/ {print \$2}" | sed "s/:.*//" > /tmp/.pkgs
    # Packages that only a build needs. Add a name here when a new leftover shows up in the top 10.
    # phpaddmod installs the toolchain again on demand, so none of these is needed at runtime.
    # Do not use "gcc.*": gcc-NN-base is a runtime dependency.
    pattern="^(binutils.*|libbinutils|libctf0|libctf-nobfd0|libsframe1|libgprofng0|libjansson4|libasan[0-9]+|libtsan[0-9]+|libhwasan0|liblsan0|libubsan1|libitm1|libgomp1|libcc1-0|libisl[0-9]+|libmpc3|libmpfr6|libc-dev-bin|m4|patch|pkgconf|pkg-config|rpcsvc-proto|perl|libperl5.*|perl-modules-.*|libdpkg-perl|gcc|gcc-[0-9]+|g\+\+.*|make|cpp.*|.*-dev)$"
    for p in $(grep -E "$pattern" /tmp/.pkgs); do
        kb="$(dpkg-query -W -f="\${Installed-Size}" "$p" 2>/dev/null || echo 0)"
        warn "package $p (${kb} KB)"
    done
    echo "== Top 10 packages (KB)"
    dpkg-query -W -f="\${Installed-Size}\t\${Package}\n" 2>/dev/null | sort -rn | head -10
    rm -f /tmp/.pkgs
else
    # Same idea as Debian, with Alpine package names
    for p in $(apk info 2>/dev/null | grep -E "^(ncurses-terminfo|build-base|gcc|g\+\+|make|binutils|perl|.*-dev|.*-doc|.*-static)$"); do
        warn "package $p"
    done
    echo "== Top 10 packages"
    for p in $(apk info 2>/dev/null); do echo "$(apk info -s "$p" 2>/dev/null | sed -n 2p) $p"; done | sort -rn | head -10
fi

# A finding when a binary still has its symbol table, because the strip step of the build was skipped
echo "== Binaries with symbols (not stripped)"
ext_dir="$(php -r "echo ini_get(\"extension_dir\");" 2>/dev/null || true)"
for f in $(command -v php) $(command -v php-fpm) $n "$ext_dir"/*.so; do
    [ -f "$f" ] || continue
    # opcache.so (PHP 8.4+) holds the string ".symtab" as data: its JIT writes ELF files for GDB
    case "$f" in */opcache.so) continue ;; esac
    # the section name table keeps ".symtab" only when the symbols are still there
    ! grep -q "\.symtab" "$f" 2>/dev/null || warn "not stripped: $f"
done

# Info only, never a finding: read it to spot what grows between releases
echo "== Top 15 files over 1 MB (MB)"
find / -xdev -type f -size +1024k -exec ls -s {} + 2>/dev/null | sort -rn | head -15 | while read -r kb path; do echo "$(mb "$kb") $path"; done
'

echo "Image: $IMAGE (threshold ${THRESHOLD_KB} KB)"
out="$(docker run --rm --entrypoint sh "$IMAGE" -c "$PROBE" 2>&1)"
echo "$out"

warns="$(printf '%s\n' "$out" | grep -c '^WARN:' || true)"
echo "----"
if [ "$warns" -gt 0 ]; then
    echo "image-slim-check: $warns finding(s)"
    exit 1
fi
echo "image-slim-check: no findings"
