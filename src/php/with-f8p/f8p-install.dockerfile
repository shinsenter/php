################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
# Copy files from the official image
COPY --link --from=frankenphp /usr/local/lib/libwatcher* /usr/local/lib/
COPY --link --from=frankenphp /usr/local/bin/frankenphp /usr/local/bin/
COPY --link --from=frankenphp /config/caddy /config/caddy
COPY --link --from=frankenphp /data/caddy /data/caddy
COPY --link --from=frankenphp /etc/caddy /etc/caddy
COPY --link --from=frankenphp /etc/frankenphp /etc/frankenphp

################################################################################
# Install FrankenPHP
RUN <<'EOF'
echo 'Install FrankenPHP'
[ -z "$DEBUG" ] || set -ex && set -e

# install common packages
APK_PACKAGES='libstdc++ mailcap libcap' \
APT_PACKAGES='libstdc++6 mailcap libcap2-bin' \
pkg-add && ldconfig /usr/local/lib

mkdir -p /config/caddy /data/caddy /etc/caddy /etc/frankenphp

! has-cmd frankenphp && exit 1

setcap cap_net_bind_service=+ep "$(command -v frankenphp)"
ln -nsf "$(command -v frankenphp)" /usr/local/sbin/caddy

EOF
