################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################

# Install RoadRunner from the original binaries
COPY --link --from=ghcr.io/roadrunner-server/roadrunner:latest /usr/bin/rr /usr/local/bin/
COPY --link --from=ghcr.io/roadrunner-server/roadrunner:latest /etc/rr.yaml /etc/

# Add yq for YAML processing
COPY --link --from=mikefarah/yq:latest /usr/bin/yq /usr/bin/yq

# Install PHP extensions
RUN phpaddmod sockets
