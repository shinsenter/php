################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
ENV NGINX_PID=/run/nginx.pid

# Nginx version to build from https://nginx.org, a number like "1.30.6".
# Required: the OS package is only a reference for the build options and is removed after the build.
# build/config.sh turns "mainline" and "stable" into a number,
# so a new release changes the image fingerprint.
ARG NGINX_VERSION=""

# Install Nginx
RUN --mount=type=bind,source=./with-nginx/nginx-build,target=/tmp/nginx-build \
    --mount=type=bind,source=./helper_cache,target=/tmp/helper_cache <<'EOF'
echo 'Install Nginx'
[ -z "$DEBUG" ] || set -x; set -e

[ -n "$NGINX_VERSION" ] || { echo 'ERROR: NGINX_VERSION must be a version number (build with build/config.sh)' >&2; exit 1; }

# One install for the OS package and the build tools.
# The OS package is only the reference of nginx-build for the configure flags.
# It is removed completely after the build, so no package record stays for an upgrade to put back.
# The build tools are removed right after the build
export APK_PACKAGES='--virtual .nginx-deps nginx build-base linux-headers openssl-dev pcre2-dev zlib-dev'
export APT_PACKAGES='nginx build-essential libssl-dev libpcre2-dev zlib1g-dev'
pkg-add

# brotli headers for the brotli module,
# installed apart so an OS without them still builds Nginx
APK_PACKAGES='--virtual .nginx-brotli brotli-dev' APT_PACKAGES='libbrotli-dev' pkg-add

# The build runs in its own shell, and a failure stops the image build
if sh /tmp/nginx-build; then
    nginx_bin="$(command -v nginx)"
    stage=/usr/src/nginx-stage

    # The OS package made the folders of the paths built into its binary, and removes them with itself
    dirs="$(nginx -V 2>&1 | tr ' ' '\n' | sed -n 's/^--[a-z-]*-path=//p' | grep -v '^stderr$' || true)"

    # Install into a stage while make and strip are still here.
    # make install leaves default configs, a sample page and charset maps that nothing uses
    make -C /usr/src/nginx install DESTDIR="$stage"
    strip --strip-all "$stage$nginx_bin" || true
    prefix="$(nginx -V 2>&1 | tr ' ' '\n' | sed -n 's/^--prefix=//p')"
    rm -rf "$stage"/etc/nginx/*.default "$stage"/etc/nginx/koi-utf "$stage"/etc/nginx/koi-win "$stage"/etc/nginx/win-utf "$stage$prefix/html"

    # Keep the libraries of the new binary, then remove the OS package completely, with the build tools.
    # On Alpine they are one virtual package, and apk refuses to remove a member of it alone
    keep-libs /usr/src/nginx/objs/nginx
    APK_PACKAGES='.nginx-deps .nginx-brotli' APT_PACKAGES='nginx nginx-common' pkg-del

    cp -a "$stage"/. /
    for path in $dirs; do mkdir -p "${path%/*}"; done
else
    echo "ERROR: cannot build Nginx $NGINX_VERSION" >&2
    exit 1
fi

rm -rf /usr/src/nginx /usr/src/nginx-stage
APK_PACKAGES='.nginx-brotli' APT_PACKAGES='libbrotli-dev' pkg-del
APK_PACKAGES='.nginx-deps' pkg-del
unset APK_PACKAGES APT_PACKAGES

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
