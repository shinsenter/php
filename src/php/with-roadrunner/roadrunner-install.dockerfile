################################################################################
# The setups in this file belong to the project https://code.shin.company/php
# I appreciate you respecting my intellectual efforts in creating them.
# If you intend to copy or use ideas from this project, please credit properly.
# Author:  SHIN Company <shin@shin.company>
# License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

ARG PHP_VERSION=${PHP_VERSION:-8.4}

# Install RoadRunner from the original binaries
COPY --link --from=ghcr.io/roadrunner-server/roadrunner:latest /usr/bin/rr /usr/local/bin/rr
COPY --link --from=ghcr.io/roadrunner-server/roadrunner:latest /etc/rr.yaml /etc/rr.yaml

# Install PHP extensions
RUN phpaddmod sockets
