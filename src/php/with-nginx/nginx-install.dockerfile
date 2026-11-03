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
# build/config.sh turns "mainline" and "stable" into a number, so a new release
# changes the image fingerprint.
ARG NGINX_VERSION=""

# Install Nginx
RUN <<'EOF'
echo 'Install Nginx'
[ -z "$DEBUG" ] || set -ex && set -e

# install nginx from the OS: users, directories, runtime libraries and the
# configure flags that the official source is built with
pkg-add nginx

# replace the binary with the official source
if [ -n "$NGINX_VERSION" ] && [ "$NGINX_VERSION" != os ]; then
    # build tools, removed right after the build
    export APK_PACKAGES='--virtual .nginx-deps build-base linux-headers openssl-dev pcre2-dev zlib-dev'
    export APT_PACKAGES='build-essential libssl-dev libpcre2-dev zlib1g-dev'
    pkg-add

    # the build runs in its own shell: a failure before "make install" leaves
    # the OS package untouched, and the build tools are removed in any case
    cat >/tmp/nginx-build.sh <<'BUILD'
set -e
echo "Build Nginx $NGINX_VERSION"

# configure flags of the OS package, without the parts that cannot be rebuilt here:
# third-party modules (--add-dynamic-module), modules that need extra libraries
# (geoip, image_filter, perl, xslt) and options removed from Nginx
eval "set -- $(nginx -V 2>&1 | sed -n 's/^configure arguments: //p')"
[ "$#" -gt 0 ]
n=$#
has_sbin=
while [ "$n" -gt 0 ]; do
    arg="$1"; shift; n=$((n - 1))
    case "$arg" in
        --add-dynamic-module=*|--with-perl_modules_path=*) continue ;;
        --with-http_geoip_module*|--with-http_image_filter_module*) continue ;;
        --with-http_perl_module*|--with-http_xslt_module*|--with-stream_geoip_module*) continue ;;
        --with-http_v2_hpack_enc|--with-http_spdy_module|--with-ipv6) continue ;;
        --sbin-path=*) has_sbin=1 ;;
    esac
    set -- "$@" "$arg"
done
# Debian leaves --sbin-path to its packaging scripts
[ -n "$has_sbin" ] || set -- "$@" --sbin-path=/usr/sbin/nginx

mkdir -p /usr/src/nginx
cd /usr/src/nginx
curl -fsSL "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" | tar -xz --strip-components=1
./configure "$@"
make -j "$(nproc)"
BUILD

    if sh /tmp/nginx-build.sh; then
        make -C /usr/src/nginx install
        rm -f /etc/nginx/*.default
    else
        echo "WARNING: cannot build Nginx $NGINX_VERSION, keep the version from the OS package" >&2
    fi

    rm -rf /usr/src/nginx /tmp/nginx-build.sh
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
