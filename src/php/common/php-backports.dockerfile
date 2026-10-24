################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Security backports for end-of-life PHP versions
#
# The official PHP images of 7.4, 8.0 and 8.1 do not get security fixes any more.
# For these versions, PHP is rebuilt in place from the source tarball kept in the
# official image (/usr/src/php.tar.xz), with the same configure flags and
# every patch in src/php-backports/php<major.minor>/, in file name order
# (<YYYYMMDD>-<NN>-<name>.patch). build/config.sh copies that folder to
# ./php-backports/ in the build context. Other versions are left untouched.
# "*.alpine.patch" and "*.debian.patch" are applied on that OS only.
#
# Check the build log: every patch and every patched file is printed, and the
# build stops when a patch does not apply.
################################################################################
# These ARGs are only used by the FROM below (base-php.dockerfile has no copy of them)
ARG BUILD_FROM_IMAGE="php"
ARG PHP_VERSION="8.5"
ARG PHP_VARIANT="fpm-alpine"

FROM ${BUILD_FROM_IMAGE}:${PHP_VERSION}-${PHP_VARIANT} AS php-base
COPY ./php-backports/ /usr/src/php-backports/

RUN --mount=type=bind,source=./common/distro-patch,target=/tmp/distro-patch <<'EOF'
set -eu

# PHP_VERSION is the full version here (set by the official image)
minor="$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')"
dir=/usr/src/php-backports/php"$minor"

if [ ! -d "$dir" ]; then
    echo "No security backports for PHP $minor"
    rm -rf /usr/src/php-backports
    exit 0
fi

os=debian
command -v apk >/dev/null 2>&1 && os=alpine

echo "Rebuilding PHP $PHP_VERSION ($os) with the backports in ${dir##*/}"

# Build dependencies (same as the official PHP Dockerfiles)
if [ "$os" = alpine ]; then
    apk add --no-cache --virtual .backports-deps \
        $PHPIZE_DEPS \
        argon2-dev \
        coreutils \
        curl-dev \
        gnu-libiconv-dev \
        libsodium-dev \
        libxml2-dev \
        linux-headers \
        oniguruma-dev \
        openssl-dev \
        patch \
        readline-dev \
        sqlite-dev
    # make sure musl's iconv doesn't get used
    rm -vf /usr/include/iconv.h
    # PHP < 8 doesn't look deeper for GNU libiconv (php-src b480e68)
    [ "${minor%%.*}" -ge 8 ] || ln -sfv /usr/include/gnu-libiconv/iconv.h /usr/include/iconv.h
else
    sh /tmp/distro-patch
    savedAptMark="$(apt-mark showmanual)"
    apt-get update
    apt-get install -y --no-install-recommends \
        libargon2-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        libreadline-dev \
        libsodium-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        patch \
        zlib1g-dev
fi

# Reuse the configure command of the installed PHP (it already has the flags of
# this variant: cli, fpm or zts)
configure_cmd="$(php -i | sed -n 's/^Configure Command => //p')"
[ -n "$configure_cmd" ]

export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    PHP_BUILD_PROVIDER='https://github.com/docker-library/php' \
    PHP_UNAME='Linux - Docker'

docker-php-source extract
cd /usr/src/php

for patchfile in "$dir"/*.patch; do
    [ -e "$patchfile" ] || continue
    case "$patchfile" in
        *.alpine.patch) [ "$os" = alpine ] || continue ;;
        *.debian.patch) [ "$os" = debian ] || continue ;;
    esac
    echo "==> Applying ${patchfile##*/}"
    patch -p1 < "$patchfile"
done

eval "$configure_cmd"
make -j "$(nproc)"
find -type f -name '*.a' -delete
make install
find /usr/local -type f -perm '/0111' -exec sh -euxc 'strip --strip-all "$@" || :' -- '{}' +

cd /
docker-php-source delete
rm -rf /usr/src/php-backports

# Remove the build tools. The official image already installed them as top-level packages.
if [ "$os" = alpine ]; then
    apk del --no-network .backports-deps
else
    apt-mark auto '.*' >/dev/null
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark >/dev/null
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
    rm -rf /var/lib/apt/lists/*
fi

rm -rf /tmp/pear ~/.pearrc

# smoke test
php --version
EOF

