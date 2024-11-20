################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Copy files from the official image
COPY --link --from=frankenphp /usr/local/lib/libwatcher* /usr/local/lib/
COPY --link --from=frankenphp /usr/local/bin/frankenphp /usr/local/bin/frankenphp

################################################################################

# Install FrankenPHP
RUN <<'EOF'
echo 'Install FrankenPHP'
[ -z "$DEBUG" ] || set -ex && set -e

# install common packages
APK_PACKAGES='libstdc++ mailcap libcap' \
APT_PACKAGES='libstdc++6 mailcap libcap2-bin' \
pkg-add && ldconfig /usr/local/lib

mkdir -p /config/caddy /data/caddy /etc/caddy

if ! has-cmd frankenphp; then
    exit 1
fi

setcap cap_net_bind_service=+ep "$(command -v frankenphp)"
ln -nsf "$(command -v frankenphp)" /usr/local/sbin/caddy

EOF
