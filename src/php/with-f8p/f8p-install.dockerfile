################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  Mai Nhut Tan <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Copy files from the official image
COPY --link --from=frankenphp /usr/local/bin/frankenphp /usr/local/bin/frankenphp

################################################################################

# Install FrankenPHP
RUN <<'EOF'
echo 'Install FrankenPHP'

set -e

# phpaddmod sockets swoole

if has-cmd frankenphp; then
    ln -nsf "$(command -v frankenphp)" /usr/local/sbin/caddy
fi

if has-cmd setcap; then
    setcap cap_net_bind_service=+ep /usr/local/bin/frankenphp
fi

if [ -x "$LEGACY_ENTRYPOINT" ]; then
    sed -i 's|php|frankenphp run|g' "$LEGACY_ENTRYPOINT"
fi
EOF
