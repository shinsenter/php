<?php
################################################################################
#     These setups are part of the project: https://code.shin.company/php
#     Please respect the intellectual effort that went into creating them.
#     If you use or copy these ideas, proper credit would be appreciated.
#      - Author:  Mai Nhut Tan <shin@shin.company>
#      - License: https://code.shin.company/php/blob/main/LICENSE
################################################################################
// A request that is still running when its replica is told to stop.
sleep(min((int) ($_GET['s'] ?? 5), 20));
echo gethostname(), "\n";
