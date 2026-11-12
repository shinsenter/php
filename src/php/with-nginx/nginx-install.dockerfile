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

# install nginx from the OS: users, directories, runtime libraries,
# and the configure flags that the official source is built with
pkg-add nginx

# replace the binary with the official source
if [ -n "$NGINX_VERSION" ] && [ "$NGINX_VERSION" != os ]; then
    # keep the runtime library: removing the build tools drops it otherwise
    # (older Alpine nginx packages link to pcre, not pcre2)
    APK_PACKAGES='pcre2' APT_PACKAGES='libpcre2-8-0' pkg-add

    # build tools, removed right after the build
    export APK_PACKAGES='--virtual .nginx-deps build-base linux-headers openssl-dev pcre2-dev zlib-dev'
    export APT_PACKAGES='build-essential libssl-dev libpcre2-dev zlib1g-dev'
    pkg-add

    # brotli headers for the brotli module,
    # installed apart so an OS without them still builds Nginx
    APK_PACKAGES='--virtual .nginx-brotli brotli-dev' APT_PACKAGES='libbrotli-dev' pkg-add

    # keep the brotli library when the headers are removed:
    # Alpine has it in brotli-libs, or in brotli on old releases, so ask which package owns it
    brotli_lib="$(apk info -W /usr/lib/libbrotlienc.so.1 2>/dev/null | sed -n 's/.* is owned by \(.*\)-[^-]*-r[0-9]*$/\1/p')"
    APK_PACKAGES="$brotli_lib" APT_PACKAGES='libbrotli1' pkg-add

    # the build runs in its own shell:
    # a failure before "make install" leaves the OS package untouched,
    # and the build tools are removed in any case
    if sh /tmp/nginx-build; then
        make -C /usr/src/nginx install
        strip --strip-all "$(type -P nginx)" || true
        # make install keeps the binary of the OS package next to the new one
        rm -f "$(type -P nginx).old" /etc/nginx/*.default
    else
        echo "WARNING: cannot build Nginx $NGINX_VERSION, keep the version from the OS package" >&2
    fi

    rm -rf /usr/src/nginx
    APK_PACKAGES='.nginx-brotli' APT_PACKAGES='libbrotli-dev' pkg-del
    APK_PACKAGES='.nginx-deps' pkg-del
    unset APK_PACKAGES APT_PACKAGES
fi

# test nginx command
nginx -V || exit 1

# clean up
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
