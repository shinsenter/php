################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
ENV APACHE_PID=/run/apache2.pid

# Apache version to build from https://httpd.apache.org, a number like "2.4.71".
# "stable" is the latest release of the 2.4 line (the only line the project publishes).
# Empty or "os" keeps the version from the OS package.
# build/config.sh turns "stable" into a number,
# so a new release changes the image fingerprint.
ARG APACHE_VERSION=""

# Install Apache2
RUN --mount=type=bind,source=./with-apache/apache-build,target=/tmp/apache-build \
    --mount=type=bind,source=./helper_cache,target=/tmp/helper_cache <<'EOF'
echo 'Install Apache2'
[ -z "$DEBUG" ] || set -x; set -e

# Install apache from the OS: users, directories and runtime libraries
APK_PACKAGES="apache2 apache2-proxy apache2-ssl apache2-utils" \
APT_PACKAGES="apache2" \
pkg-add

# Alpine ships HTTP/2 and brotli as separate packages (Debian has them in apache2),
# each one apart so an old release without one still installs the other
APK_PACKAGES="apache2-http2" pkg-add || true
APK_PACKAGES="apache2-brotli" pkg-add || true

# Replace the binary and the modules with the official source, so that every variant
# runs the same Apache version. The OS package stays when the build fails (an OS too old)
if [ -n "$APACHE_VERSION" ] && [ "$APACHE_VERSION" != os ]; then
    # Keep the runtime library: removing the build tools drops it otherwise
    # (older OS releases link Apache to PCRE, not PCRE2)
    APK_PACKAGES='nghttp2-libs pcre2' APT_PACKAGES='libnghttp2-14 libpcre2-8-0' pkg-add

    # Build tools, removed right after the build
    export APK_PACKAGES='--virtual .apache-deps build-base linux-headers apr-dev apr-util-dev nghttp2-dev openssl-dev pcre2-dev zlib-dev'
    export APT_PACKAGES='build-essential libapr1-dev libaprutil1-dev libnghttp2-dev libssl-dev libpcre2-dev zlib1g-dev'
    pkg-add

    # brotli headers for mod_brotli, installed apart so an OS without them still builds Apache
    APK_PACKAGES='--virtual .apache-brotli brotli-dev' APT_PACKAGES='libbrotli-dev' pkg-add

    # Keep the brotli library when the headers are removed:
    # Alpine has it in brotli-libs, or in brotli on old releases, so ask which package owns it
    brotli_lib="$(apk info -W /usr/lib/libbrotlienc.so.1 2>/dev/null | sed -n 's/.* is owned by \(.*\)-[^-]*-r[0-9]*$/\1/p')"
    APK_PACKAGES="$brotli_lib" APT_PACKAGES='libbrotli1' pkg-add

    # The build runs in its own shell:
    # a failure before the copy leaves the OS package untouched,
    # and the build tools are removed in any case
    if sh /tmp/apache-build; then
        module_dir="$(dirname "$(find /usr/lib -type f -name mod_mpm_event.so | head -n 1)")"
        apache_bin="$(command -v apache2 || command -v httpd)"
        cp -f "/usr/src/httpd-stage$module_dir"/*.so "$module_dir"/
        cp -f "/usr/src/httpd-stage/usr/sbin/${apache_bin##*/}" "$apache_bin"
        strip --strip-all "$apache_bin" || true

        # The package records still name the OS version, and scanners report it for the new binary
        if [ -f /var/lib/dpkg/status ]; then
            awk -v p=apache2 -v n="$APACHE_VERSION" 'function swap(s, o, r,   out, i) {
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
            awk -v p=apache2 -v n="$APACHE_VERSION-r0" 'function swap(s, o, r,   out, i) {
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
        echo "WARNING: cannot build Apache $APACHE_VERSION, keep the version from the OS package, which may lack security fixes" >&2
        APACHE_VERSION=os
    fi

    rm -rf /usr/src/httpd /usr/src/httpd-stage
    APK_PACKAGES='.apache-brotli' APT_PACKAGES='libbrotli-dev' pkg-del
    APK_PACKAGES='.apache-deps' pkg-del
    unset APK_PACKAGES APT_PACKAGES
fi

# Clean up
\rm -rf /etc/init.d/apache* \
    /etc/ssl/apache* \
    /var/www \
    /etc/apache2/modules* \
    /etc/apache2/conf.d \
    /etc/apache2/conf-*/* \
    /etc/apache2/mods-*/* \
    /etc/apache2/sites-*/* \
    /etc/apache2/apache2.conf \
    /etc/apache2/httpd.conf \
    /etc/apache2/ports.conf \
    $APP_PATH/*

# Copy mime types
if [ -f /etc/mime.types ]; then
    cp -rf /etc/mime.types /etc/apache2/mime.types
fi

# Link modules directory
module_dir="$(dirname $(find /usr/lib/ -type f -name mod_mpm_event.so | head -n 1))"
if [ -d "$module_dir" ]; then
    \rm -rf /etc/apache2/modules
    ln -nsf "$module_dir" /etc/apache2/modules

    if has-cmd strip; then
        strip --strip-all --strip-debug "$module_dir"/*.so
    fi
fi

# Alias for apache2
if has-cmd httpd && ! has-cmd apache2; then
    ln -nsf "$(type -P httpd)" "/usr/local/sbin/apache2"
fi

# Test apache command
apache2 -v || exit 1

# A build that succeeded must give the requested version (a failed one fell back to APACHE_VERSION=os above)
if [ -n "$APACHE_VERSION" ] && [ "$APACHE_VERSION" != os ]; then
    apache_now="$(apache2 -v | sed -n 's|^Server version: Apache/\([0-9.]*\).*|\1|p')"
    [ "$apache_now" = "$APACHE_VERSION" ] || { echo "ERROR: Apache is $apache_now, not $APACHE_VERSION" >&2; exit 1; }
fi

EOF
