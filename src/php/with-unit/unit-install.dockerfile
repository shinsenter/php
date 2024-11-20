################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG PHP_VERSION=${PHP_VERSION:-8.4}
ARG BUILD_SOURCE_IMAGE=${BUILD_SOURCE_IMAGE:-https://codeload.github.com/nginx/unit/legacy.tar.gz/refs/heads/branches/default}
ADD $BUILD_SOURCE_IMAGE /tmp/unit.tar.gz

ENV UNIT_CONTROL_PID=/run/unit.pid
ENV UNIT_CONTROL_SOCKET=/run/control.unit.sock

# Install Nginx
RUN <<'EOF'
echo 'Install Nginx Unit'
[ -z "$DEBUG" ] || set -ex && set -e

if [ ! -f "/tmp/unit.tar.gz" ]; then
    exit 1
fi

# install dependencies
APK_PACKAGES="openssl-dev" \
APT_PACKAGES="libssl-dev" \
pkg-add $PHPIZE_DEPS

# extract Unit source
mkdir -p /tmp/unit
tar -xzf /tmp/unit.tar.gz --strip=1 -C "/tmp/unit"

cd /tmp/unit
NCPU="$(getconf _NPROCESSORS_ONLN)"
DEB_HOST_MULTIARCH="$(dpkg-architecture -q DEB_HOST_MULTIARCH)"
CC_OPT="$(DEB_BUILD_MAINT_OPTIONS="hardening=+all,-pie" DEB_CFLAGS_MAINT_APPEND="-Wp,-D_FORTIFY_SOURCE=2 -fPIC" dpkg-buildflags --get CFLAGS)"
LD_OPT="$(DEB_BUILD_MAINT_OPTIONS="hardening=+all,-pie" DEB_LDFLAGS_MAINT_APPEND="-Wl,--as-needed -pie" dpkg-buildflags --get LDFLAGS)"

build() {
    local name="${1:-unitd}"
    local mod_dir="/usr/lib/unit/${name}-modules"
    local args="--no-regex --no-pcre2 --openssl \
        --user=$APP_USER \
        --control=unix:$UNIT_CONTROL_SOCKET \
        --pid=$UNIT_CONTROL_PID \
        --libdir=/usr/lib/$DEB_HOST_MULTIARCH \
        --modulesdir=$mod_dir \
        --statedir=/var/lib/unit \
        --runstatedir=/var/run \
        --logdir=/var/log \
        --tmpdir=/var/tmp \
        --log=$(log-path)"
    shift

    # make -j $NCPU -C pkg/contrib .njs
    # export PKG_CONFIG_PATH=$(pwd)/pkg/contrib/njs/build
    # ./configure $args --njs --cc-opt="$CC_OPT" --ld-opt="$LD_OPT" "$@"
    # make -j $NCPU unitd
    # test -d /usr/local/sbin || install -d /usr/local/sbin
    # install -p -m755 build/sbin/unitd /usr/local/sbin/$name
    # make clean

    # ./configure $args --cc-opt="$CC_OPT" "$@"
    # ./configure php --module=php
    # make -j $NCPU php-install
    # test -d $mod_dir || install -d $mod_dir
    # install -p build/lib/unit/modules/*.unit.so $mod_dir
    # make clean

    ./configure $args --cc-opt="$CC_OPT" "$@"
    ./configure php --module=php
    make -j $NCPU
    test -d $mod_dir || install -d $mod_dir
    test -d /usr/local/sbin || install -d /usr/local/sbin
    install -p build/lib/unit/modules/*.unit.so $mod_dir
    install -p -m755 build/sbin/unitd /usr/local/sbin/$name
    make clean
}

build unitd-debug --debug
build unitd

cd $HOME

# clean up
rm -rf /tmp/*
EOF
