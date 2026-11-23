################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
ENV APACHE_PID=/run/apache2.pid

# Apache version to build, a number like "2.4.71" ("stable" is the latest 2.4 release)
# Set by build/config.sh, so a new release changes the image fingerprint
ARG APACHE_VERSION=""

# Install Apache2
RUN --mount=type=bind,source=./with-apache/apache-build,target=/tmp/apache-build \
    --mount=type=bind,source=./helper_cache,target=/tmp/helper_cache <<'EOF'
echo 'Install Apache2'
[ -z "$DEBUG" ] || set -x; set -e

[ -n "$APACHE_VERSION" ] || { echo 'ERROR: APACHE_VERSION must be a version number (build with build/config.sh)' >&2; exit 1; }

# OS package: the reference of apache-build for paths, limits and modules, removed after the build
# Build tools: removed right after the build
export APK_PACKAGES='--virtual .apache-deps apache2 apache2-proxy apache2-ssl apache2-utils build-base linux-headers apr-dev apr-util-dev nghttp2-dev openssl-dev pcre2-dev zlib-dev'
export APT_PACKAGES='apache2 build-essential libapr1-dev libaprutil1-dev libnghttp2-dev libssl-dev libpcre2-dev zlib1g-dev'
pkg-add

# Brotli headers, apart so an OS without them still builds Apache
APK_PACKAGES='--virtual .apache-brotli brotli-dev' APT_PACKAGES='libbrotli-dev' pkg-add

# A build failure stops the image build
if sh /tmp/apache-build; then
    module_dir="$(dirname "$(find /usr/lib -type f -name mod_mpm_event.so | head -n 1)")"
    apache_bin="$(command -v apache2 || command -v httpd)"
    stage=/usr/src/httpd-stage

    # Strip and keep the libraries while the build tools are here, keep envvars of the OS package
    # Tools of apache2-utils: rotatelogs is in sbin of the stage, installed to /usr/bin
    tools="$stage/usr/sbin/rotatelogs $stage/usr/bin/htpasswd $stage/usr/bin/htdigest"
    strip --strip-all "$stage/usr/sbin/${apache_bin##*/}" $tools "$stage$module_dir"/*.so || true
    keep-libs "$stage/usr/sbin/${apache_bin##*/}" $tools "$stage$module_dir"/*.so
    [ ! -f /etc/apache2/envvars ] || cp -p /etc/apache2/envvars /tmp/apache-envvars

    # Remove the OS package with the build tools (one virtual package on Alpine)
    APK_PACKAGES='.apache-deps .apache-brotli' APT_PACKAGES='apache2 apache2-bin apache2-data apache2-utils' pkg-del

    mkdir -p "$module_dir" /etc/apache2
    cp -f "$stage$module_dir"/*.so "$module_dir"/
    cp -f "$stage/usr/sbin/${apache_bin##*/}" "$apache_bin"
    cp -f $tools /usr/bin/
    cp -f "$stage/etc/apache2/mime.types" /etc/apache2/mime.types 2>/dev/null || true
    [ ! -f /tmp/apache-envvars ] || mv -f /tmp/apache-envvars /etc/apache2/envvars
else
    echo "ERROR: cannot build Apache $APACHE_VERSION" >&2
    exit 1
fi

rm -rf /usr/src/httpd /usr/src/httpd-stage
APK_PACKAGES='.apache-brotli' APT_PACKAGES='libbrotli-dev' pkg-del
APK_PACKAGES='.apache-deps' pkg-del
unset APK_PACKAGES APT_PACKAGES

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

# The binary must have the requested version
apache_now="$(apache2 -v | sed -n 's|^Server version: Apache/\([0-9.]*\).*|\1|p')"
[ "$apache_now" = "$APACHE_VERSION" ] || { echo "ERROR: Apache is $apache_now, not $APACHE_VERSION" >&2; exit 1; }

EOF
