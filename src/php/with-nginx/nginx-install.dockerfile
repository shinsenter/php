################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
ENV NGINX_PID=/run/nginx.pid

# Nginx version to build from https://nginx.org, a number like "1.30.6".
# Empty or "os" keeps the version from the OS package.
# build/config.sh turns "mainline" and "stable" into a number,
# so a new release changes the image fingerprint.
ARG NGINX_VERSION=""

# Install Nginx
RUN --mount=type=bind,source=./with-nginx/nginx-build,target=/tmp/nginx-build \
    --mount=type=bind,source=./helper_cache,target=/tmp/helper_cache <<'EOF'
echo 'Install Nginx'
[ -z "$DEBUG" ] || set -x; set -e

# Install nginx from the OS: users, directories, runtime libraries,
# and the configure flags that the official source is built with
pkg-add nginx

# Replace the binary with the official source
if [ -n "$NGINX_VERSION" ] && [ "$NGINX_VERSION" != os ]; then
    # Keep the runtime library: removing the build tools drops it otherwise
    # (older Alpine nginx packages link to pcre, not pcre2)
    APK_PACKAGES='pcre2' APT_PACKAGES='libpcre2-8-0' pkg-add

    # Build tools, removed right after the build
    export APK_PACKAGES='--virtual .nginx-deps build-base linux-headers openssl-dev pcre2-dev zlib-dev'
    export APT_PACKAGES='build-essential libssl-dev libpcre2-dev zlib1g-dev'
    pkg-add

    # brotli headers for the brotli module,
    # installed apart so an OS without them still builds Nginx
    APK_PACKAGES='--virtual .nginx-brotli brotli-dev' APT_PACKAGES='libbrotli-dev' pkg-add

    # Keep the brotli library when the headers are removed:
    # Alpine has it in brotli-libs, or in brotli on old releases, so ask which package owns it
    brotli_lib="$(apk info -W /usr/lib/libbrotlienc.so.1 2>/dev/null | sed -n 's/.* is owned by \(.*\)-[^-]*-r[0-9]*$/\1/p')"
    APK_PACKAGES="$brotli_lib" APT_PACKAGES='libbrotli1' pkg-add

    # The build runs in its own shell:
    # a failure before "make install" leaves the OS package untouched,
    # and the build tools are removed in any case
    if sh /tmp/nginx-build; then
        make -C /usr/src/nginx install
        strip --strip-all "$(type -P nginx)" || true
        # make install keeps the binary of the OS package next to the new one
        rm -f "$(type -P nginx).old" /etc/nginx/*.default

        # The package records still name the OS version, and scanners report it for the new binary
        if [ -f /var/lib/dpkg/status ]; then
            awk -v p=nginx -v n="$NGINX_VERSION" 'function swap(s, o, r,   out, i) {
                while ((i = index(s, o)) > 0) { out = out substr(s, 1, i - 1) r; s = substr(s, i + length(o)) }
                return out s
            }
            BEGIN { RS = ""; ORS = "\n\n" }
            $0 ~ "(^|\n)Package: " p "(-[^\n]*)?(\n|$)" && match($0, /(^|\n)Version: [^\n]*/) {
                v = substr($0, RSTART, RLENGTH); sub(/^\n?Version: /, "", v); $0 = swap($0, v, n)
            }
            { print }' /var/lib/dpkg/status > /tmp/dpkg-status && cat /tmp/dpkg-status > /var/lib/dpkg/status
            rm -f /tmp/dpkg-status
        fi
        # Same for the Alpine package database
        if [ -f /lib/apk/db/installed ]; then
            awk -v p=nginx -v n="$NGINX_VERSION-r0" 'function swap(s, o, r,   out, i) {
                while ((i = index(s, o)) > 0) { out = out substr(s, 1, i - 1) r; s = substr(s, i + length(o)) }
                return out s
            }
            BEGIN { RS = ORS = "\n\n" }
            $0 ~ "(^|\n)P:" p "(-[^\n]*)?\n" && match($0, /\nV:[^\n]*/) {
                o = substr($0, RSTART + 3, RLENGTH - 3); $0 = swap($0, o, n)
            }
            { print }' /lib/apk/db/installed > /tmp/apk-installed && cat /tmp/apk-installed > /lib/apk/db/installed
            rm -f /tmp/apk-installed
        fi
    else
        echo "WARNING: cannot build Nginx $NGINX_VERSION, keep the version from the OS package, which may lack security fixes" >&2
        NGINX_VERSION=os
    fi

    rm -rf /usr/src/nginx
    APK_PACKAGES='.nginx-brotli' APT_PACKAGES='libbrotli-dev' pkg-del
    APK_PACKAGES='.nginx-deps' pkg-del
    unset APK_PACKAGES APT_PACKAGES
fi

# Test nginx command
nginx -V || exit 1

# A build that succeeded must give the requested version (a failed one fell back to NGINX_VERSION=os above)
if [ -n "$NGINX_VERSION" ] && [ "$NGINX_VERSION" != os ]; then
    nginx_now="$(nginx -v 2>&1 | sed -n 's|^nginx version: nginx/\([0-9.]*\).*|\1|p')"
    [ "$nginx_now" = "$NGINX_VERSION" ] || { echo "ERROR: Nginx is $nginx_now, not $NGINX_VERSION" >&2; exit 1; }
fi

# Clean up
\rm -rf /var/www/localhost \
    /etc/init.d/nginx* \
    /etc/ssl/nginx* \
    /etc/nginx/nginx.conf \
    /etc/nginx/http.d \
    /etc/nginx/modules-* \
    /etc/nginx/sites-* \
    /etc/nginx/conf-* \
    "$APP_PATH"/*
EOF
